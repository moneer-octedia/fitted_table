import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'fitted_table_column.dart';
import 'fitted_table_row.dart';
import 'fitted_table_cell.dart';
import 'fitted_table_theme.dart';

class FittedTable<T> extends StatelessWidget {
  FittedTable({
    super.key,
    required this.visibleNumberOfColumns,
    required this.columns,
    this.onTapDataRow,
    required List<FittedTableRow> rows,
  }) : child = _DataReadyFittedTable<T>(
          rows: rows,
        );

  FittedTable.paginated({
    super.key,
    required this.visibleNumberOfColumns,
    required this.columns,
    this.onTapDataRow,
    required Future<List<T>> Function(int pageKey, int pageSize) future,
    required FittedTableRow<T> Function(
            BuildContext context, T value, int index)
        dataRowBuilder,
  }) : child = _PaginatedFittedTable<T>(
          future: future,
          dataRowBuilder: dataRowBuilder,
        );

  static FittedTable<T> of<T>(BuildContext context) {
    return context.findAncestorWidgetOfExactType<FittedTable<T>>()!;
  }

  final int visibleNumberOfColumns;
  final List<FittedTableColumn> columns;
  final void Function(T value)? onTapDataRow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }

  double? resolveEvenColumnWidth(
      BuildContext context, BoxConstraints constraints) {
    final fittedTableThemeData = FittedTableTheme.of(context);
    int evenColumnNumber = visibleNumberOfColumns;
    double totalSpecifiedWidth = 0.0;

    for (var i = 0; i < visibleNumberOfColumns; i += 1) {
      final columnWidth = columns[i].width;
      if (columnWidth != null) {
        evenColumnNumber -= 1;
        totalSpecifiedWidth += columnWidth;
      }
    }

    double? evenColumnWidth;

    if (evenColumnNumber != 0) {
      evenColumnWidth = constraints.maxWidth / evenColumnNumber;

      evenColumnWidth -= totalSpecifiedWidth / evenColumnNumber;

      if (fittedTableThemeData.dataRowPadding?.horizontal != null) {
        evenColumnWidth -=
            fittedTableThemeData.dataRowPadding!.horizontal / evenColumnNumber;
      }
    }

    return evenColumnWidth;
  }
}

class _DataReadyFittedTable<T> extends StatelessWidget {
  const _DataReadyFittedTable({
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

      List<Widget> buildSliverRows() {
        List<Widget> fittedTableDataRows = [];
        for (var i = 0; i < rows.length; i += 1) {
          final row = rows[i];

          fittedTableDataRows.add(
            SliverToBoxAdapter(
              child: _FittedTableDataRow<T>(
                constraints: constraints,
                evenColumnWidth: evenColumnWidth,
                value: row.value,
                index: i,
                fittedTableRow: row,
              ),
            ),
          );
        }

        return fittedTableDataRows;
      }

      return CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: _FittedTableHeaderRow<T>(
                constraints: constraints,
                evenColumnWidth: evenColumnWidth,
              ),
            ),
          ),
          ...buildSliverRows()
        ],
      );
      // return ListView.builder(itemBuilder: widget.dataRowBuilder)
    });
  }
}

const int _pageSize = 10;

class _PaginatedFittedTable<T> extends StatefulWidget {
  const _PaginatedFittedTable({
    Key? key,
    required this.future,
    required this.dataRowBuilder,
  }) : super(key: key);

  final Future<List<T>> Function(int pageKey, int pageSize) future;
  final FittedTableRow<T> Function(BuildContext context, T value, int index)
      dataRowBuilder;

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
      return CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: _FittedTableHeaderRow<T>(
                constraints: constraints,
                evenColumnWidth: evenColumnWidth,
              ),
            ),
          ),
          PagedSliverList(
            pagingController: pagingController,
            addAutomaticKeepAlives: true,
            builderDelegate: PagedChildBuilderDelegate<T>(
                itemBuilder: (context, value, index) {
              final fittedTableRow =
                  widget.dataRowBuilder(context, value, index);

              return _FittedTableDataRow(
                constraints: constraints,
                evenColumnWidth: evenColumnWidth,
                value: value,
                index: index,
                fittedTableRow: fittedTableRow,
              );
            }),
          ),
        ],
      );
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
      {Key? key, required this.constraints, this.evenColumnWidth})
      : super(key: key);

  final BoxConstraints constraints;
  final double? evenColumnWidth;

  @override
  Widget build(BuildContext context) {
    final fittedTable = FittedTable.of<T>(context);
    final fittedTableThemeData = FittedTableTheme.of(context);

    List<Widget> children = [];

    for (var i = 0; i < fittedTable.visibleNumberOfColumns; i += 1) {
      final column = fittedTable.columns[i];
      assert(column.width != null || evenColumnWidth != null);
      children.add(
        SizedBox(
          width: column.width ?? evenColumnWidth,
          child: Align(alignment: column.alignment, child: column.title),
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

class _FittedTableDataRow<T> extends StatefulWidget {
  const _FittedTableDataRow(
      {Key? key,
      required this.value,
      required this.index,
      required this.constraints,
      this.evenColumnWidth,
      required this.fittedTableRow})
      : super(key: key);

  final T value;
  final int index;
  final BoxConstraints constraints;
  final double? evenColumnWidth;
  final FittedTableRow fittedTableRow;

  @override
  State<_FittedTableDataRow<T>> createState() => _FittedTableDataRowState<T>();
}

class _FittedTableDataRowState<T> extends State<_FittedTableDataRow<T>>
    with AutomaticKeepAliveClientMixin {
  bool isExpanded = false;

  @override
  bool get wantKeepAlive => isExpanded;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final fittedTable = FittedTable.of<T>(context);
    final fittedTableThemeData = FittedTableTheme.of(context);

    final List<Widget> children = [];

    for (var i = 0; i < fittedTable.visibleNumberOfColumns; i += 1) {
      final fittedTableCell = widget.fittedTableRow.cells[i];
      final column = fittedTable.columns[i];
      assert(column.width != null || widget.evenColumnWidth != null);
      final isExpandColumn = column is ExpandFittedTableColumn;
      assert(() {
        if (isExpandColumn) {
          return fittedTableCell is ExpandFittedTableCell;
        }
        return true;
      }());
      children.add(
        SizedBox(
          width: column.width ?? widget.evenColumnWidth,
          child: Align(
              alignment: column.alignment,
              child: isExpandColumn
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      padding: EdgeInsets.zero,
                      icon: (fittedTableCell as ExpandFittedTableCell).content)
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
            height: fittedTableThemeData.dataRowPadding!.horizontal / 2,
          ),
          _FittedTableExpand<T>(
            fittedTableRow: widget.fittedTableRow,
          )
        ],
      );
    }

    if (fittedTableThemeData.dataRowPadding != null) {
      row = Padding(padding: fittedTableThemeData.dataRowPadding!, child: row);
    }

    final isEven = widget.index % 2 == 0;

    if (isEven && fittedTableThemeData.evenDataRowColor != null) {
      row =
          ColoredBox(color: fittedTableThemeData.evenDataRowColor!, child: row);
    } else if (!isEven && fittedTableThemeData.oddDataRowColor != null) {
      row =
          ColoredBox(color: fittedTableThemeData.oddDataRowColor!, child: row);
    }

    if (fittedTable.onTapDataRow != null) {
      row = InkWell(
          onTap: () => fittedTable.onTapDataRow!(widget.value), child: row);
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
