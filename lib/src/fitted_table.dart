library fitted_table_lib;

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'fitted_table_theme.dart';

part 'fitted_column.dart';

part 'fitted_cell.dart';

part 'fitted_row.dart';

class FittedTable<T> extends StatelessWidget {
  FittedTable({
    super.key,
    required this.visibleNumberOfColumns,
    required this.columns,
    this.onTapRow,
    required List<FittedTableRow> rows,
    this.shrinkWrap = false,
  }) : child = _FittedTableWithRowList<T>(
          rows: rows,
        );

  FittedTable.builder({
    super.key,
    required this.visibleNumberOfColumns,
    required this.columns,
    this.onTapRow,
    required FittedTableRow Function(BuildContext context, int index)
        rowBuilder,
    int? rowCount,
    this.shrinkWrap = false,
  }) : child = _FittedTableWithRowBuilder<T>(
          rowBuilder: rowBuilder,
          rowCount: rowCount,
        );

  FittedTable.paginated({
    super.key,
    required this.visibleNumberOfColumns,
    required this.columns,
    this.onTapRow,
    required Future<List<T>> Function(int pageKey, int pageSize) future,
    required FittedTableRow<T> Function(
            BuildContext context, T value, int index)
        rowBuilder,
    WidgetBuilder? firstPageErrorIndicatorBuilder,
    WidgetBuilder? newPageErrorIndicatorBuilder,
    WidgetBuilder? firstPageProgressIndicatorBuilder,
    WidgetBuilder? newPageProgressIndicatorBuilder,
    WidgetBuilder? noItemsFoundIndicatorBuilder,
    WidgetBuilder? noMoreItemsIndicatorBuilder,
    this.shrinkWrap = false,
  }) : child = _PaginatedFittedTable<T>(
          future: future,
          rowBuilder: rowBuilder,
          firstPageErrorIndicatorBuilder: firstPageErrorIndicatorBuilder,
          newPageErrorIndicatorBuilder: newPageErrorIndicatorBuilder,
          firstPageProgressIndicatorBuilder: firstPageProgressIndicatorBuilder,
          newPageProgressIndicatorBuilder: newPageProgressIndicatorBuilder,
          noItemsFoundIndicatorBuilder: noItemsFoundIndicatorBuilder,
          noMoreItemsIndicatorBuilder: noMoreItemsIndicatorBuilder,
        );

  static FittedTable<T> of<T>(BuildContext context) {
    return context.findAncestorWidgetOfExactType<FittedTable<T>>()!;
  }

  final int visibleNumberOfColumns;
  final List<FittedColumn> columns;
  final void Function(T value)? onTapRow;
  final Widget child;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final fittedTableThemeData = FittedTableTheme.of(context);

    return Material(
        clipBehavior: Clip.hardEdge,
        shape: fittedTableThemeData.aroundBorder == null
            ? null
            : RoundedRectangleBorder(
                side: fittedTableThemeData.aroundBorder!,
              ),
        child: child);
  }

  @visibleForTesting
  double resolveEvenColumnWidth(
      BuildContext context, BoxConstraints constraints) {
    final fittedTableThemeData = FittedTableTheme.of(context);
    int evenColumnNumber = visibleNumberOfColumns;
    double totalSpecifiedWidth =
        (columns.length - 1) * fittedTableThemeData.space;

    double evenColumnWidth = constraints.maxWidth / evenColumnNumber;

    for (var i = 0; i < visibleNumberOfColumns; i += 1) {
      final column = columns[i];

      if (column is FittedFlexedColumn) {
        evenColumnNumber += column.flex - 1;
        evenColumnWidth = constraints.maxWidth / evenColumnNumber;
      } else if (column is FittedTightColumn) {
        evenColumnNumber -= 1;
        evenColumnWidth = constraints.maxWidth / evenColumnNumber;
        totalSpecifiedWidth += column.width;
      } else if (column is FittedUtilityColumn && column.width != null) {
        evenColumnNumber -= 1;
        evenColumnWidth = constraints.maxWidth / evenColumnNumber;
        totalSpecifiedWidth += column.width!;
      }
    }

    evenColumnWidth -= totalSpecifiedWidth / evenColumnNumber;

    if (fittedTableThemeData.rowPadding?.horizontal != null) {
      evenColumnWidth -=
          fittedTableThemeData.rowPadding!.horizontal / evenColumnNumber;
    }

    return evenColumnWidth;
  }
}

class _FittedTableWithRowList<T> extends StatelessWidget {
  const _FittedTableWithRowList({
    Key? key,
    required this.rows,
  }) : super(key: key);

  final List<FittedTableRow> rows;

  @override
  Widget build(BuildContext context) {
    final fittedTable = FittedTable.of<T>(context);
    return LayoutBuilder(builder: (context, constraints) {
      final evenColumnWidth =
          fittedTable.resolveEvenColumnWidth(context, constraints);

      final scrollView = CustomScrollView(
        shrinkWrap: fittedTable.shrinkWrap,
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                for (var i = rows.length; i < rows.length; i += 1)
                  _FittedTableRow<T>(
                    constraints: constraints,
                    evenColumnWidth: evenColumnWidth,
                    value: rows[i].value,
                    index: i,
                    fittedTableRow: rows[i],
                  ),
              ],
              addAutomaticKeepAlives: true,
            ),
          )
        ],
      );

      return Column(
        children: [
          _FittedTableHeaderRow<T>(
            constraints: constraints,
            evenColumnWidth: evenColumnWidth,
          ),
          if (!fittedTable.shrinkWrap)
            Expanded(
              child: scrollView,
            )
          else
            scrollView
        ],
      );
    });
  }
}

class _FittedTableWithRowBuilder<T> extends StatelessWidget {
  const _FittedTableWithRowBuilder({
    Key? key,
    required this.rowBuilder,
    this.rowCount,
  }) : super(key: key);

  final FittedTableRow Function(BuildContext context, int index) rowBuilder;
  final int? rowCount;

  @override
  Widget build(BuildContext context) {
    final fittedTable = FittedTable.of<T>(context);

    return LayoutBuilder(builder: (context, constraints) {
      final evenColumnWidth =
          fittedTable.resolveEvenColumnWidth(context, constraints);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FittedTableHeaderRow<T>(
            constraints: constraints,
            evenColumnWidth: evenColumnWidth,
          ),
          Flexible(
            fit: FlexFit.loose,
            child: CustomScrollView(
              shrinkWrap: fittedTable.shrinkWrap,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final row = rowBuilder(context, index);
                      return _FittedTableRow<T>(
                        constraints: constraints,
                        evenColumnWidth: evenColumnWidth,
                        value: row.value,
                        index: index,
                        fittedTableRow: row,
                      );
                    },
                    addAutomaticKeepAlives: true,
                    childCount: rowCount,
                  ),
                )
              ],
            ),
          )
        ],
      );
    });
  }
}

const int _pageSize = 10;

class _PaginatedFittedTable<T> extends StatefulWidget {
  const _PaginatedFittedTable({
    Key? key,
    required this.future,
    required this.rowBuilder,
    this.firstPageErrorIndicatorBuilder,
    this.newPageErrorIndicatorBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.noItemsFoundIndicatorBuilder,
    this.noMoreItemsIndicatorBuilder,
  }) : super(key: key);

  final Future<List<T>> Function(int pageKey, int pageSize) future;
  final FittedTableRow<T> Function(BuildContext context, T value, int index)
      rowBuilder;

  final WidgetBuilder? firstPageErrorIndicatorBuilder;
  final WidgetBuilder? newPageErrorIndicatorBuilder;
  final WidgetBuilder? firstPageProgressIndicatorBuilder;
  final WidgetBuilder? newPageProgressIndicatorBuilder;
  final WidgetBuilder? noItemsFoundIndicatorBuilder;
  final WidgetBuilder? noMoreItemsIndicatorBuilder;

  @override
  State<_PaginatedFittedTable<T>> createState() =>
      _PaginatedFittedTableState<T>();
}

class _PaginatedFittedTableState<T> extends State<_PaginatedFittedTable<T>> {
  final PagingController<int, T> pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    pagingController.addPageRequestListener(fetchPage);
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  Future<void> fetchPage(int pageKey) async {
    try {
      final newValueList = await widget.future(pageKey, _pageSize);

      final isLastPage = newValueList.length < _pageSize;

      if (isLastPage) {
        pagingController.appendLastPage(newValueList);
      } else {
        final nextPageKey = pageKey + newValueList.length;
        pagingController.appendPage(newValueList, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fittedTable = FittedTable.of<T>(context);
    return LayoutBuilder(builder: (context, constraints) {
      final evenColumnWidth =
          fittedTable.resolveEvenColumnWidth(context, constraints);

      final scrollView = Expanded(
        child: CustomScrollView(
          shrinkWrap: fittedTable.shrinkWrap,
          slivers: [
            PagedSliverList(
              pagingController: pagingController,
              addAutomaticKeepAlives: true,
              builderDelegate: PagedChildBuilderDelegate<T>(
                  firstPageErrorIndicatorBuilder:
                      widget.firstPageErrorIndicatorBuilder,
                  newPageErrorIndicatorBuilder:
                      widget.newPageErrorIndicatorBuilder,
                  firstPageProgressIndicatorBuilder:
                      widget.firstPageProgressIndicatorBuilder,
                  newPageProgressIndicatorBuilder:
                      widget.newPageProgressIndicatorBuilder,
                  noItemsFoundIndicatorBuilder:
                      widget.noItemsFoundIndicatorBuilder,
                  noMoreItemsIndicatorBuilder:
                      widget.noMoreItemsIndicatorBuilder,
                  itemBuilder: (context, value, index) {
                    final fittedTableRow =
                        widget.rowBuilder(context, value, index);

                    return _FittedTableRow(
                      constraints: constraints,
                      evenColumnWidth: evenColumnWidth,
                      value: value,
                      index: index,
                      fittedTableRow: fittedTableRow,
                    );
                  }),
            ),
          ],
        ),
      );

      return Column(children: [
        FlexibleSpaceBar(
          background: _FittedTableHeaderRow<T>(
            constraints: constraints,
            evenColumnWidth: evenColumnWidth,
          ),
        ),
        if (!fittedTable.shrinkWrap)
          Expanded(
            child: scrollView,
          )
        else
          scrollView
      ]);
    });
    // return RefreshIndicator(
    //   onRefresh: () => Future.sync(
    //     () => pagingController.refresh(),
    //   ),
    //   child:
    // );
  }
}

class _FittedTableHeaderRow<T> extends StatelessWidget {
  const _FittedTableHeaderRow(
      {Key? key, required this.constraints, required this.evenColumnWidth})
      : super(key: key);

  final BoxConstraints constraints;
  final double evenColumnWidth;

  double resolveFinalColumnWidth(FittedColumn fittedColumn) {
    if (fittedColumn is FittedFlexedColumn) {
      return evenColumnWidth * fittedColumn.flex;
    } else if (fittedColumn is FittedTightColumn) {
      return fittedColumn.width;
    } else if (fittedColumn is FittedUtilityColumn &&
        fittedColumn.width != null) {
      return fittedColumn.width!;
    }

    return evenColumnWidth;
  }

  @override
  Widget build(BuildContext context) {
    final fittedTable = FittedTable.of<T>(context);
    final fittedTableThemeData = FittedTableTheme.of(context);

    List<Widget> children = [];

    Widget? utility;

    for (var i = 0; i < fittedTable.visibleNumberOfColumns; i += 1) {
      final fittedColumn = fittedTable.columns[i];
      final child = SizedBox(
        width: resolveFinalColumnWidth(fittedColumn),
        child:
            Align(alignment: fittedColumn.alignment, child: fittedColumn.title),
      );

      if (fittedColumn is FittedUtilityColumn &&
          fittedTableThemeData.utilityAtEnd) {
        utility = child;
      } else if (fittedColumn is! FittedUtilityColumn ||
          !fittedTableThemeData.utilityAtEnd) {
        children.add(child);
      }
    }

    if (utility != null) {
      children.add(utility);
    }

    Widget row = Row(
        mainAxisAlignment: fittedTableThemeData.mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children);

    if (fittedTableThemeData.headerDefaultTextStyle != null) {
      row = DefaultTextStyle(
          style: fittedTableThemeData.headerDefaultTextStyle!, child: row);
    }

    if (fittedTableThemeData.headerRowPadding != null) {
      row =
          Padding(padding: fittedTableThemeData.headerRowPadding!, child: row);
    }

    if (fittedTableThemeData.headerRowColor != null) {
      row = ColoredBox(color: fittedTableThemeData.headerRowColor!, child: row);
    }

    return row;
  }
}

class _FittedTableRow<T> extends StatefulWidget {
  const _FittedTableRow(
      {Key? key,
      required this.value,
      required this.index,
      required this.constraints,
      required this.evenColumnWidth,
      required this.fittedTableRow})
      : super(key: key);

  final T value;
  final int index;
  final BoxConstraints constraints;
  final double evenColumnWidth;
  final FittedTableRow fittedTableRow;

  @override
  State<_FittedTableRow<T>> createState() => _FittedTableRowState<T>();
}

class _FittedTableRowState<T> extends State<_FittedTableRow<T>>
    with AutomaticKeepAliveClientMixin {
  bool isExpanded = false;

  @override
  bool get wantKeepAlive => isExpanded;

  double resolveFinalColumnWidth(FittedColumn fittedColumn) {
    var evenColumnWidth = widget.evenColumnWidth;
    if (fittedColumn is FittedFlexedColumn) {
      return evenColumnWidth * fittedColumn.flex;
    }
    if (fittedColumn is FittedTightColumn) {
      return fittedColumn.width;
    } else if (fittedColumn is FittedUtilityColumn &&
        fittedColumn.width != null) {
      return fittedColumn.width!;
    }

    return evenColumnWidth;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final fittedTable = FittedTable.of<T>(context);
    final fittedTableThemeData = FittedTableTheme.of(context);

    final List<Widget> children = [];

    Widget? utility;

    for (var i = 0; i < fittedTable.visibleNumberOfColumns; i += 1) {
      final fittedTableRow = widget.fittedTableRow;
      final fittedTableCell = fittedTableRow.cells[i];
      final fittedColumn = fittedTable.columns[i];
      // assert(column.width != null || widget.evenColumnWidth != null);
      // final isExpandColumn = column is ExpandFittedColumn;
      assert(() {
        // if (isExpandColumn) {
        //   return fittedTableCell is ExpandTableCell;
        // }
        return true;
      }());
      if (fittedColumn is FittedUtilityColumn) {
        utility = SizedBox(
          width: resolveFinalColumnWidth(fittedColumn),
          child: Align(
              alignment: AlignmentDirectional.topStart,
              child: () {
                Widget? expandIcon;
                Widget? child1;
                if (fittedColumn.expandIcon != null) {
                  expandIcon = IconButton(
                      splashRadius: 18,
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      padding: EdgeInsets.zero,
                      icon: fittedColumn.expandIcon!);
                }

                if (fittedColumn.builder1 != null) {
                  child1 = fittedColumn.builder1!.call(fittedTableRow.value);
                }

                if (expandIcon != null && child1 != null) {
                  return Row(
                    children: fittedTableThemeData.expandIconFirst
                        ? [expandIcon, child1]
                        : [child1, expandIcon],
                  );
                }

                if (expandIcon != null) {
                  return expandIcon;
                }

                if (child1 != null) {
                  return child1;
                }
              }()),
        );
      }

      if (fittedColumn is FittedUtilityColumn &&
          !fittedTableThemeData.utilityAtEnd) {
        children.add(utility!);
      } else if (fittedColumn is! FittedUtilityColumn) {
        children.add(
          SizedBox(
            width: resolveFinalColumnWidth(fittedColumn),
            child: Align(
                alignment: AlignmentDirectional.topStart,
                child: fittedTableCell.content),
          ),
        );
      }
    }

    if (fittedTableThemeData.utilityAtEnd && utility != null) {
      children.add(utility);
    }

    Widget row = Row(
        mainAxisAlignment: fittedTableThemeData.mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children);

    if (isExpanded) {
      row = Column(
        children: [
          row,
          SizedBox(
            height: fittedTableThemeData.rowPadding!.horizontal / 2,
          ),
          _FittedTableExpand<T>(
            fittedTableRow: widget.fittedTableRow,
          )
        ],
      );
    }

    if (fittedTableThemeData.rowPadding != null) {
      row = Padding(padding: fittedTableThemeData.rowPadding!, child: row);
    }

    if (fittedTableThemeData.rowDivider != null) {
      row = DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: fittedTableThemeData.rowDivider!),
        ),
        child: row,
      );
    }

    final isEven = widget.index % 2 == 0;

    if (isEven && fittedTableThemeData.evenRowColor != null) {
      row = ColoredBox(color: fittedTableThemeData.evenRowColor!, child: row);
    } else if (!isEven && fittedTableThemeData.oddRowColor != null) {
      row = ColoredBox(color: fittedTableThemeData.oddRowColor!, child: row);
    }

    if (fittedTable.onTapRow != null) {
      row =
          InkWell(onTap: () => fittedTable.onTapRow!(widget.value), child: row);
    }

    return row;
  }
}

class _FittedTableExpand<T> extends StatelessWidget {
  const _FittedTableExpand({required this.fittedTableRow});

  final FittedTableRow fittedTableRow;

  @override
  Widget build(BuildContext context) {
    final fittedTable = FittedTable.of<T>(context);
    final fittedTableThemeData = FittedTableTheme.of(context);

    List<Widget> cells = [];
    for (var i = fittedTable.visibleNumberOfColumns;
        i < fittedTable.columns.length;
        i += 1) {
      final title = fittedTable.columns[i].title;
      final content = fittedTableRow.cells[i].content;
      cells.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fittedTableThemeData.expandHeaderDefaultTextStyle != null)
              DefaultTextStyle(
                  style: fittedTableThemeData.headerDefaultTextStyle!,
                  child: title)
            else
              title,
            SizedBox(width: fittedTableThemeData.expandWidthPadding),
            Expanded(child: content),
          ],
        ),
      );
      if (i != fittedTable.columns.length - 1) {
        cells.add(SizedBox(height: fittedTableThemeData.expandHeightPadding));
      }
    }

    return Column(
      children: cells,
    );
  }
}
