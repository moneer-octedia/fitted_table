part of fitted_table_lib;

class FittedCell {
  const FittedCell({required this.content});

  const factory FittedCell.expand({required Widget icon}) =
      _ExpandFittedCell;

  final Widget content;
}

class _ExpandFittedCell extends FittedCell {
  const _ExpandFittedCell({required Widget icon}) : super(content: icon);
}