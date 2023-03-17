import 'fitted_cell.dart';

class FittedTableRow<T> {
  const FittedTableRow({
    required this.cells,
    this.value,
  });

  final T? value;
  final List<FittedTableCell> cells;
}