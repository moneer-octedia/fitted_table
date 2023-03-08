import 'package:flutter/material.dart';

class FittedTableColumn {
  const FittedTableColumn(
      {required this.title,
      this.width,
      this.alignment = AlignmentDirectional.centerStart});

  final Widget title;
  final double? width;
  final AlignmentGeometry alignment;
}

class ExpandFittedTableColumn extends FittedTableColumn {
  ExpandFittedTableColumn(
      {super.title = const SizedBox(), super.width, super.alignment});
}
