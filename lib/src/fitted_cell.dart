part of fitted_table_lib;

class FittedCell {
  const FittedCell({required this.content});

  const factory FittedCell.expand() = _ExpandFittedCell;

  final Widget content;
}

class _ExpandFittedCell extends FittedCell {
  const _ExpandFittedCell() : super(content: const SizedBox());
}
