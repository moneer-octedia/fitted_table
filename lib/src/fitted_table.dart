library fitted_table_lib;

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'fitted_row.dart';
import 'fitted_cell.dart';
import 'fitted_table_theme.dart';

part 'fitted_column.dart';

class FittedTable<T> extends StatelessWidget {
  FittedTable({
    super.key,
    required this.visibleNumberOfColumns,
    required this.columns,
    this.onTapRow,
    required List<FittedTableRow> rows,
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

  @override
  Widget build(BuildContext context) {
    return child;
  }

  @visibleForTesting
  double resolveEvenColumnWidth(
      BuildContext context, BoxConstraints constraints) {
    final fittedTableThemeData = FittedTableTheme.of(context);
    int evenColumnNumber = visibleNumberOfColumns;
    double totalSpecifiedWidth = 0.0;
    double evenColumnWidth = constraints.maxWidth / evenColumnNumber;

    for (var i = 0; i < visibleNumberOfColumns; i += 1) {
      final column = columns[i];

      if (column is FittedFlexedColumn) {
        evenColumnNumber += column.flex - 1;
      } else if (column is FittedTightColumn) {
        evenColumnNumber -= 1;
        totalSpecifiedWidth += column.width;
      } else if (column is FittedExpandColumn && column.width != null) {
        evenColumnNumber -= 1;
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

      return Column(
        children: [
          _FittedTableHeaderRow<T>(
            constraints: constraints,
            evenColumnWidth: evenColumnWidth,
          ),
          CustomScrollView(
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
          ),
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
        children: [
          _FittedTableHeaderRow<T>(
            constraints: constraints,
            evenColumnWidth: evenColumnWidth,
          ),
          Expanded(
            child: CustomScrollView(
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
          ),
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
      return Column(children: [
        FlexibleSpaceBar(
          background: _FittedTableHeaderRow<T>(
            constraints: constraints,
            evenColumnWidth: evenColumnWidth,
          ),
        ),
        Expanded(
          child: CustomScrollView(
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
        )
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
    //
    // if (fittedColumn is FittedFlexedColumn) {
    //
    // } else
    if (fittedColumn is FittedTightColumn) {
      return fittedColumn.width;
    } else if (fittedColumn is FittedExpandColumn &&
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

    for (var i = 0; i < fittedTable.visibleNumberOfColumns; i += 1) {
      final fittedColumn = fittedTable.columns[i];
      // assert(column.width != null || evenColumnWidth != null);
      children.add(
        SizedBox(
          width: resolveFinalColumnWidth(fittedColumn),
          child: Align(
              alignment: fittedColumn.alignment, child: fittedColumn.title),
        ),
      );
    }

    Widget row = Row(
        mainAxisAlignment: fittedTableThemeData.mainAxisAlignment,
        children: children);

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
    //
    // if (fittedColumn is FittedFlexedColumn) {
    //
    // } else
    if (fittedColumn is FittedTightColumn) {
      return fittedColumn.width;
    } else if (fittedColumn is FittedExpandColumn &&
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

    for (var i = 0; i < fittedTable.visibleNumberOfColumns; i += 1) {
      final fittedTableCell = widget.fittedTableRow.cells[i];
      final fittedColumn = fittedTable.columns[i];
      // assert(column.width != null || widget.evenColumnWidth != null);
      // final isExpandColumn = column is ExpandFittedColumn;
      assert(() {
        // if (isExpandColumn) {
        //   return fittedTableCell is ExpandTableCell;
        // }
        return true;
      }());
      children.add(
        SizedBox(
          width: resolveFinalColumnWidth(fittedColumn),
          child: Align(
              alignment: fittedColumn.alignment,
              child: fittedColumn is FittedExpandColumn
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      padding: EdgeInsets.zero,
                      icon: fittedTableCell.content)
                  : fittedTableCell.content),
        ),
      );
    }

    Widget row = Row(
        mainAxisAlignment: fittedTableThemeData.mainAxisAlignment,
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

    List<Widget> cells = [];
    for (var i = fittedTable.visibleNumberOfColumns;
        i < fittedTable.columns.length;
        i += 1) {
      final title = fittedTable.columns[i].title;
      final content = fittedTableRow.cells[i].content;
      cells.add(
        Row(
          children: [
            title,
            const SizedBox(width: 8),
            content,
          ],
        ),
      );
    }

    return Column(
      children: cells,
    );
  }
}
