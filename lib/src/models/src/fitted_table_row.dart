import 'package:flutter/material.dart';
import 'fitted_table_cell.dart';

class FittedTableRow<T> {
  const FittedTableRow({
    required this.cells,
    this.color,
    this.padding,
    this.onTap,
  });

  final List<FittedTableCell> cells;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final void Function(T value)? onTap;
}
