import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'models/models.dart';

const int _pageSize = 10;

class FittedTable<T> extends StatefulWidget {
  const FittedTable({
    Key? key,
    required this.future,
    required this.rowBuilder,
    required this.visibleNumberOfColumns,
    required this.columns,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
  }) : super(key: key);

  final Future<List<T>> Function(int pageKey, int pageSize) future;
  final FittedTableRow<T> Function(BuildContext context, T value, int index)
      rowBuilder;
  final int visibleNumberOfColumns;
  final List<FittedTableColumn> columns;
  final MainAxisAlignment mainAxisAlignment;

  @override
  State<FittedTable<T>> createState() => _FittedTableState<T>();
}

class _FittedTableState<T> extends State<FittedTable<T>> {
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

  Widget buildRow(FittedTableRow<T> fittedTableRow, T value) {
    Widget row = LayoutBuilder(builder: (context, constraints) {
      int evenColumnNumber = widget.visibleNumberOfColumns;
      double totalSpecifiedWidth = 0.0;

      assert(widget.columns.length == fittedTableRow.cells.length);

      for (var i = 0; i < widget.columns.length; i += 1) {
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

      for (var i = 0; i < widget.columns.length; i += 1) {
        final fittedTableCellContent = fittedTableRow.cells[i].content;
        final column = widget.columns[i];
        assert(column.width != null || evenColumnWidth != null);
        children.add(
          SizedBox(
            width: column.width ?? evenColumnWidth,
            child: Align(
                alignment: column.alignment, child: fittedTableCellContent),
          ),
        );
      }

      return Row(
          mainAxisAlignment: widget.mainAxisAlignment, children: children);
    });

    if (fittedTableRow.padding != null) {
      row = Padding(padding: fittedTableRow.padding!, child: row);
    }

    if (fittedTableRow.color != null) {
      row = ColoredBox(color: fittedTableRow.color!, child: row);
    }

    if (fittedTableRow.onTap != null) {
      row = InkWell(onTap: () => fittedTableRow.onTap!(value), child: row);
    }

    return row;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => pagingController.refresh(),
      ),
      child: PagedListView(
        pagingController: pagingController,
        builderDelegate: PagedChildBuilderDelegate<T>(
          animateTransitions: true,
          itemBuilder: (context, value, index) {
            final fittedTableRow = widget.rowBuilder(context, value, index);
            return buildRow(fittedTableRow, value);
          },
        ),
      ),
    );
  }
}
