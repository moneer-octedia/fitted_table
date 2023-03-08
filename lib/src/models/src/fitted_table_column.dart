import 'package:flutter/material.dart';

class FittedTableColumn {
  const FittedTableColumn({required this.title, this.excessWidthPercentage});

  final Widget title;
  final double? excessWidthPercentage;
}
