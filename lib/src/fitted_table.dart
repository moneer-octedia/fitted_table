import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'models/models.dart';

const int _pageSize = 10;

class FittedTable<T> extends StatefulWidget {
  const FittedTable(
      {Key? key,
      required this.future,
      required this.dataRowBuilder,
      required this.visibleNumberOfColumns,
      required this.columns,
      this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
      this.evenDataRowColor,
      this.dataRowPadding,
      this.onTapDataRow,
      this.oddDataRowColor,
      this.headerRowColor,
      this.headerRowPadding,
      this.expandableDataRows = true})
      : super(key: key);

  final Future<List<T>> Function(int pageKey, int pageSize) future;
  final FittedTableRow<T> Function(BuildContext context, T value, int index)
      dataRowBuilder;
  final int visibleNumberOfColumns;
  final List<FittedTableColumn> columns;
  final MainAxisAlignment mainAxisAlignment;
  final Color? evenDataRowColor;
  final Color? oddDataRowColor;
  final Color? headerRowColor;
  final EdgeInsetsGeometry? dataRowPadding;
  final EdgeInsetsGeometry? headerRowPadding;
  final void Function(T value)? onTapDataRow;
  final bool expandableDataRows;

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
          mainAxisAlignment: widget.mainAxisAlignment, children: children);
    });

    if (widget.headerRowPadding != null) {
      row = Padding(padding: widget.headerRowPadding!, child: row);
    }

    if (widget.headerRowColor != null) {
      row = ColoredBox(color: widget.headerRowColor!, child: row);
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
                    dataRowBuilder: widget.dataRowBuilder,
                    visibleNumberOfColumns: widget.visibleNumberOfColumns,
                    columns: widget.columns,
                    mainAxisAlignment: widget.mainAxisAlignment,
                    expandableDataRows: widget.expandableDataRows,
                    evenDataRowColor: widget.evenDataRowColor,
                    oddDataRowColor: widget.oddDataRowColor,
                    onTapDataRow: widget.onTapDataRow,
                    dataRowPadding: widget.dataRowPadding,
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
      required this.dataRowBuilder,
      required this.visibleNumberOfColumns,
      required this.columns,
      required this.mainAxisAlignment,
      this.evenDataRowColor,
      this.oddDataRowColor,
      this.headerRowColor,
      this.dataRowPadding,
      this.onTapDataRow,
      required this.expandableDataRows,
      required this.value,
      required this.index, required this.constraints})
      : super(key: key);

  final FittedTableRow<T> Function(BuildContext context, T value, int index)
      dataRowBuilder;
  final int visibleNumberOfColumns;
  final List<FittedTableColumn> columns;
  final MainAxisAlignment mainAxisAlignment;
  final Color? evenDataRowColor;
  final Color? oddDataRowColor;
  final Color? headerRowColor;
  final EdgeInsetsGeometry? dataRowPadding;
  final void Function(T value)? onTapDataRow;
  final bool expandableDataRows;
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
    super.build(context);
    final fittedTableRow =
        widget.dataRowBuilder(context, widget.value, widget.index);

      int evenColumnNumber = widget.visibleNumberOfColumns;
      double totalSpecifiedWidth = 0.0;

      assert(widget.columns.length == fittedTableRow.cells.length);

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
        evenColumnWidth = widget.constraints.maxWidth / evenColumnNumber;

        evenColumnWidth -= totalSpecifiedWidth / evenColumnNumber;
        if (widget.dataRowPadding?.horizontal != null) {
          evenColumnWidth -= widget.dataRowPadding!.horizontal / evenColumnNumber;
        }
      }

      for (var i = 0; i < widget.visibleNumberOfColumns; i += 1) {
        final fittedTableCell = fittedTableRow.cells[i];
        final column = widget.columns[i];
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
                        icon:
                            (fittedTableCell as ExpandFittedTableCell).content)
                    : fittedTableCell.content),
          ),
        );
      }

      Widget row =
          Row(mainAxisAlignment: widget.mainAxisAlignment, children: children);

      if (isExpanded) {
        row = Column(
          children: [
            row,
            SizedBox(
              height: 120,
              child: const Placeholder(),
            ),
          ],
        );
      }



    if (widget.dataRowPadding != null) {
      row = Padding(padding: widget.dataRowPadding!, child: row);
    }

    final isEven = widget.index % 2 == 0;

    if (isEven && widget.evenDataRowColor != null) {
      row = ColoredBox(color: widget.evenDataRowColor!, child: row);
    } else if (!isEven && widget.oddDataRowColor != null) {
      row = ColoredBox(color: widget.oddDataRowColor!, child: row);
    }

    if (widget.onTapDataRow != null) {
      row =
          InkWell(onTap: () => widget.onTapDataRow!(widget.value), child: row);
    }

    return row;
  }
}
