import 'package:flutter/material.dart';
import 'fitted_table_cell.dart';

class FittedTableRow<T> {
  const FittedTableRow({
    required this.cells,
  });

  final List<FittedTableCell> cells;
}
