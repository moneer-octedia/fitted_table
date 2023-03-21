part of fitted_table_lib;

class FittedColumn {
  const FittedColumn(
      {required this.title, this.alignment = AlignmentDirectional.centerStart});

  const factory FittedColumn.expand(
      {Widget title,
      double? width,
      AlignmentGeometry alignment}) = FittedExpandColumn;

  const factory FittedColumn.flex(
      {required Widget title,
      required int flex,
      AlignmentGeometry alignment}) = FittedFlexedColumn;

  const factory FittedColumn.tight(
      {required Widget title,
      required double width,
      AlignmentGeometry alignment}) = FittedTightColumn;

  // const factory FittedColumn.iconButton({
  //   Widget title,
  //   double? width,
  //   AlignmentGeometry alignment,
  //   required void Function(Object value) onPressed,
  // }) = _FittedIconButtonColumn;

  final Widget title;

  final AlignmentGeometry alignment;
}

@visibleForTesting
class FittedExpandColumn extends FittedColumn {
  const FittedExpandColumn(
      {super.title = const SizedBox(), this.width, super.alignment});

  final double? width;
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

// class _FittedIconButtonColumn extends FittedColumn {
//   const _FittedIconButtonColumn({
//     super.title = const SizedBox(),
//     this.width,
//     super.alignment,
//     required this.onPressed,
//   });
//
//   final void Function(Object value) onPressed;
//   final double? width;
// }
