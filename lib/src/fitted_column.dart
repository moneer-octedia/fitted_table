part of fitted_table_lib;

class FittedColumn {
  const FittedColumn(
      {required this.title, this.alignment = AlignmentDirectional.centerStart});

  const factory FittedColumn.utility(
      {Widget title,
      double? width,
      AlignmentGeometry alignment,
      Widget? expandIcon,
      Widget Function(dynamic value)? builder1}) = FittedUtilityColumn;

  const factory FittedColumn.flex(
      {required Widget title,
      required int flex,
      AlignmentGeometry alignment}) = FittedFlexedColumn;

  const factory FittedColumn.tight(
      {required Widget title,
      required double width,
      AlignmentGeometry alignment}) = FittedTightColumn;

  final Widget title;

  final AlignmentGeometry alignment;
}

@visibleForTesting
class FittedUtilityColumn extends FittedColumn {
  const FittedUtilityColumn({
    super.title = const SizedBox(),
    this.width,
    super.alignment,
    this.expandIcon,
    this.builder1,
  });

  final double? width;
  final Widget? expandIcon;
  final Widget Function(dynamic value)? builder1;
}

@visibleForTesting
class FittedFlexedColumn extends FittedColumn {
  const FittedFlexedColumn(
      {required super.title, required this.flex, super.alignment});

  final int flex;
}

@visibleForTesting
class FittedTightColumn extends FittedColumn {
  const FittedTightColumn(
      {required super.title, required this.width, super.alignment});

  final double width;
}
