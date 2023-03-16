import 'package:flutter/material.dart';

class FittedTableCell {
  const FittedTableCell({required this.content});

  final Widget content;
}

class ExpandFittedTableCell extends FittedTableCell {
  ExpandFittedTableCell({required Widget icon}) : super(content: icon);
}

