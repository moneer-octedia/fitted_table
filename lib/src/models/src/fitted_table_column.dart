import 'package:flutter/material.dart';

enum FittedTableColumnWidth {
  leastWidth,

}

class FittedTableColumn {
  const FittedTableColumn({required this.title, this.width,
  this.alignment = AlignmentDirectional.centerStart});

  final Widget title;
  final double? width;
  final AlignmentGeometry alignment;
}
