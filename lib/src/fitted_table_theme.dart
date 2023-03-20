import 'package:flutter/material.dart';

class FittedTableTheme extends InheritedWidget {
  const FittedTableTheme(
      {super.key, required this.fittedTableThemeData, required super.child});

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
    this.evenRowColor,
    this.oddRowColor,
    this.headerRowColor,
    this.rowPadding,
    this.headerRowPadding,
    this.headerTextStyle,
  });

  final MainAxisAlignment mainAxisAlignment;
  final Color? evenRowColor;
  final Color? oddRowColor;
  final Color? headerRowColor;
  final TextStyle? headerTextStyle;
  final EdgeInsetsGeometry? rowPadding;
  final EdgeInsetsGeometry? headerRowPadding;
  final bool expandableDataRows;
}
