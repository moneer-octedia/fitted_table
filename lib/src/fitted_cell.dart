import 'package:flutter/material.dart';

class FittedTableCell {
  const FittedTableCell({required this.content});

  final Widget content;
}

class ExpandFittedCell extends FittedTableCell {
  ExpandFittedCell({required Widget icon}) : super(content: icon);
}

