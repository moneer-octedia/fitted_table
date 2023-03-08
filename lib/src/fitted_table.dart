import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'models/models.dart';

const int _pageSize = 10;

class FittedTable<T> extends StatefulWidget {
  const FittedTable({
    Key? key,
    required this.future,
    required this.dataRowBuilder,
    required this.visibleNumberOfColumns,
    required this.columns,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.evenDataRowColor,
    this.dataRowPadding,
    this.onTapDataRow,
    this.oddDataRowColor, this.headerRowColor, this.headerRowPadding,
  }) : super(key: key);

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
        final column = widget.columns[i];
        assert(column.width != null || evenColumnWidth != null);
        children.add(
          SizedBox(
            width: column.width ?? evenColumnWidth,
            child: Align(
                alignment: column.alignment, child: column.title),
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

  Widget buildDataRow(BuildContext context, T value, int index) {
    final fittedTableRow = widget.dataRowBuilder(context, value, index);

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

    if (widget.dataRowPadding != null) {
      row = Padding(padding: widget.dataRowPadding!, child: row);
    }

    final isEven = index % 2 == 0;

    if (isEven && widget.evenDataRowColor != null) {
      row = ColoredBox(color: widget.evenDataRowColor!, child: row);
    } else if (!isEven && widget.oddDataRowColor != null) {
      row = ColoredBox(color: widget.oddDataRowColor!, child: row);
    }

    if (widget.onTapDataRow != null) {
      row = InkWell(onTap: () => widget.onTapDataRow!(value), child: row);
    }

    return row;
  }

  @override
  Widget build(BuildContext context) {
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
          builderDelegate: PagedChildBuilderDelegate<T>(
            animateTransitions: true,
            itemBuilder: buildDataRow,
          ),
        ),
      ],
    );
    // return RefreshIndicator(
    //   onRefresh: () => Future.sync(
    //     () => pagingController.refresh(),
    //   ),
    //   child:
    // );
  }
}
