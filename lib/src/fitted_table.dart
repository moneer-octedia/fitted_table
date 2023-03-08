import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'models/models.dart';

const int _pageSize = 10;

class FittedTable<T> extends StatefulWidget {
  const FittedTable({
    Key? key,
    required this.future,
    required this.rowBuilder,
    required this.visibleColumnCounter,
    required this.columns,
  }) : super(key: key);

  final Future<List<T>> Function(int pageKey, int pageSize) future;
  final FittedTableRow<T> Function(BuildContext context, T value, int index)
      rowBuilder;
  final int visibleColumnCounter;
  final List<FittedTableColumn> columns;

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

  bool hasAtLestOneExcessWidthPercentageSet() {
    for (var column in widget.columns) {
      if (column.excessWidthPercentage != null) {
        return true;
      }
    }
    return false;
  }

  Widget buildRow(FittedTableRow<T> fittedTableRow, T value) {
    final useExpandedOnAllCells = !hasAtLestOneExcessWidthPercentageSet();

    Widget row;
    if (useExpandedOnAllCells) {
      row = Row(
        children: [
          for (FittedTableCell cell in fittedTableRow.cells)
            Expanded(child: cell.content)
        ],
      );
    } else {
      List<Widget> buildCells(BoxConstraints constraints) {
        final maxWidth = constraints.maxWidth;
        final decimalIndividualCellWidth =
            maxWidth / widget.visibleColumnCounter;
        final reminder = decimalIndividualCellWidth % 1;
        final totalReminderWidth = reminder * widget.visibleColumnCounter;
        final individualCellWidth = decimalIndividualCellWidth - reminder;

        assert(totalReminderWidth != 0);
        List<Widget> cells = [];
        for (var i = 0; i < widget.columns.length; i += 1) {
          final percentOfRemainderWidth =
              widget.columns[i].excessWidthPercentage;

          cells.add(
            SizedBox(
              width: percentOfRemainderWidth == null
                  ? individualCellWidth
                  : individualCellWidth +
                      (percentOfRemainderWidth * totalReminderWidth),
              child: fittedTableRow.cells[i].content,
            ),
          );
        }
        return cells;
      }

      row = LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: buildCells(constraints),
          );
        },
      );
    }

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
