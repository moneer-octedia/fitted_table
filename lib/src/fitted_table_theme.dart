import 'package:flutter/material.dart';

class FittedTableTheme extends InheritedWidget {
  const FittedTableTheme({required this.fittedTableThemeData, required super.child});

  static FittedTableThemeData of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FittedTableTheme>()!
        .fittedTableThemeData;
  }

  final FittedTableThemeData fittedTableThemeData;

  @override
  bool updateShouldNotify(covariant FittedTableTheme oldWidget) {
    return oldWidget.fittedTableThemeData != fittedTableThemeData;
  }
}

class FittedTableThemeData {
  const FittedTableThemeData({
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.expandableDataRows = false,
    this.evenDataRowColor,
    this.oddDataRowColor,
    this.headerRowColor,
    this.dataRowPadding,
    this.headerRowPadding,
  });

  final MainAxisAlignment mainAxisAlignment;
  final Color? evenDataRowColor;
  final Color? oddDataRowColor;
  final Color? headerRowColor;
  final EdgeInsetsGeometry? dataRowPadding;
  final EdgeInsetsGeometry? headerRowPadding;
  final bool expandableDataRows;
}
