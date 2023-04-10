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
    this.space = 12,
    this.expandableDataRows = false,
    this.evenRowColor,
    this.oddRowColor,
    this.headerRowColor,
    this.rowPadding,
    this.headerRowPadding,
    this.headerTextStyle,
    this.expandHeightPadding = 12,
    this.expandWidthPadding = 12,
    this.expandTitleStyle,
  });

  final MainAxisAlignment mainAxisAlignment;
  final Color? evenRowColor;
  final Color? oddRowColor;
  final Color? headerRowColor;
  final TextStyle? headerTextStyle;
  final EdgeInsetsGeometry? rowPadding;
  final EdgeInsetsGeometry? headerRowPadding;
  final bool expandableDataRows;
  final double expandHeightPadding;
  final double expandWidthPadding;
  final TextStyle? expandTitleStyle;
  final double space;
}
