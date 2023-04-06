part of fitted_table_lib;

class FittedTableRow<T> {
  const FittedTableRow({
    required this.cells,
    this.value,
    this.expandAction,
  });

  final T? value;
  final List<FittedCell> cells;
  final Widget? expandAction;
}