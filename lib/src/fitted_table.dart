import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'fitted_table_column.dart';
import 'fitted_table_row.dart';
import 'fitted_table_cell.dart';
import 'fitted_table_theme.dart';

const int _pageSize = 10;

class FittedTable<T> extends StatefulWidget {
  const FittedTable({
    Key? key,
    required this.future,
    required this.dataRowBuilder,
    required this.visibleNumberOfColumns,
    required this.columns,
    this.onTapDataRow,
  }) : super(key: key);

  final Future<List<T>> Function(int pageKey, int pageSize) future;
  final FittedTableRow<T> Function(BuildContext context, T value, int index)
      dataRowBuilder;
  final int visibleNumberOfColumns;
  final List<FittedTableColumn> columns;
  final void Function(T value)? onTapDataRow;

  @override
  State<FittedTable<T>> createState() => _FittedTableState<T>();
}

class _FittedTableState<T> extends State<FittedTable<T>> {
  final PagingController<int, T> pagingController =
      PagingController(firstPageKey: 0);

  FittedTableThemeData get fittedTableThemeData => FittedTableTheme.of(context);

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

  Widget buildHeaderRow() {
    Widget row = LayoutBuilder(builder: (context, constraints) {
      int evenColumnNumber = widget.visibleNumberOfColumns;
      double totalSpecifiedWidth = 0.0;

      for (var i = 0; i < widget.visibleNumberOfColumns; i += 1) {
        final columnWidth = widget.columns[i].width;
        if (columnWidth != null) {
          evenColumnNumber -= 1;
          totalSpecifiedWidth += columnWidth;
        }
      }

      List<Widget> children = [];

      double? evenColumnWidth;

      if (evenColumnNumber != 0) {
        evenColumnWidth = constraints.maxWidth / evenColumnNumber;

        evenColumnWidth -= totalSpecifiedWidth / evenColumnNumber;
      }

      for (var i = 0; i < widget.visibleNumberOfColumns; i += 1) {
        final column = widget.columns[i];
        assert(column.width != null || evenColumnWidth != null);
        children.add(
          SizedBox(
            width: column.width ?? evenColumnWidth,
            child: Align(alignment: column.alignment, child: column.title),
          ),
        );
      }

      return Row(
          mainAxisAlignment: fittedTableThemeData.mainAxisAlignment,
          children: children);
    });

    if (fittedTableThemeData.headerRowPadding != null) {
      row =
          Padding(padding: fittedTableThemeData.headerRowPadding!, child: row);
    }

    if (fittedTableThemeData.headerRowColor != null) {
      row = ColoredBox(color: fittedTableThemeData.headerRowColor!, child: row);
    }

    return row;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: buildHeaderRow(),
            ),
          ),
          PagedSliverList(
            pagingController: pagingController,
            addAutomaticKeepAlives: true,
            builderDelegate: PagedChildBuilderDelegate<T>(
                itemBuilder: (context, value, index) {
              return _FittedBoxDataRow(
                constraints: constraints,
                value: value,
                index: index,
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

class _FittedBoxDataRow<T> extends StatefulWidget {
  const _FittedBoxDataRow(
      {Key? key,
      required this.value,
      required this.index,
      required this.constraints})
      : super(key: key);

  final T value;
  final int index;
  final BoxConstraints constraints;

  @override
  State<_FittedBoxDataRow<T>> createState() => _FittedBoxDataRowState<T>();
}

class _FittedBoxDataRowState<T> extends State<_FittedBoxDataRow<T>>
    with AutomaticKeepAliveClientMixin {
  bool isExpanded = false;

  @override
  bool get wantKeepAlive => isExpanded;

  @override
  Widget build(BuildContext context) {
    final table = context.findAncestorWidgetOfExactType<FittedTable<T>>()!;

    super.build(context);
    final fittedTableThemeData = FittedTableTheme.of(context);

    final fittedTableRow =
        table.dataRowBuilder(context, widget.value, widget.index);

    int evenColumnNumber = table.visibleNumberOfColumns;
    double totalSpecifiedWidth = 0.0;

    assert(table.columns.length == fittedTableRow.cells.length);

    for (var i = 0; i < table.visibleNumberOfColumns; i += 1) {
      final columnWidth = table.columns[i].width;
      if (columnWidth != null) {
        evenColumnNumber -= 1;
        totalSpecifiedWidth += columnWidth;
      }
    }

    List<Widget> children = [];

    double? evenColumnWidth;

    if (evenColumnNumber != 0) {
      evenColumnWidth = widget.constraints.maxWidth / evenColumnNumber;

      evenColumnWidth -= totalSpecifiedWidth / evenColumnNumber;
      if (fittedTableThemeData.dataRowPadding?.horizontal != null) {
        evenColumnWidth -=
            fittedTableThemeData.dataRowPadding!.horizontal / evenColumnNumber;
      }
    }

    for (var i = 0; i < table.visibleNumberOfColumns; i += 1) {
      final fittedTableCell = fittedTableRow.cells[i];
      final column = table.columns[i];
      assert(column.width != null || evenColumnWidth != null);
      final isExpandColumn = column is ExpandFittedTableColumn;
      assert(() {
        if (isExpandColumn) {
          return fittedTableCell is ExpandFittedTableCell;
        }
        return true;
      }());
      children.add(
        SizedBox(
          width: column.width ?? evenColumnWidth,
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
          _FittedTableExpand<T>(
            fittedTableRow: fittedTableRow,
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

    if (table.onTapDataRow != null) {
      row =
          InkWell(onTap: () => table.onTapDataRow!(widget.value), child: row);
    }

    return row;
  }
}

class _FittedTableExpand<T> extends StatelessWidget {
  const _FittedTableExpand({required this.fittedTableRow});

  final FittedTableRow fittedTableRow;

  @override
  Widget build(BuildContext context) {
    final table = context.findAncestorWidgetOfExactType<FittedTable<T>>()!;

    List<Widget> cells = [];
    for (var i = table.visibleNumberOfColumns; i < table.columns.length; i += 1) {
      final title = table.columns[i].title;
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
