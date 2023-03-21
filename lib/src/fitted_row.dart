part of fitted_table_lib;

class FittedTableRow<T> {
  const FittedTableRow({
    required this.cells,
    this.value,
  });

  final T? value;
  final List<FittedCell> cells;
}