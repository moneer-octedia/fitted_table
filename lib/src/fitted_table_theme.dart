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
    this.space = 8,
    this.evenRowColor,
    this.oddRowColor,
    this.headerRowColor,
    this.rowPadding,
    this.headerRowPadding,
    this.expandHeightPadding = 8,
    this.expandWidthPadding = 8,
    this.rowDivider,
    this.utilityAtEnd = false,
    this.expandIconFirst = false,
    this.aroundBorder,
    this.headerDefaultTextStyle,
    this.expandHeaderDefaultTextStyle,
  });

  final MainAxisAlignment mainAxisAlignment;
  final Color? evenRowColor;
  final Color? oddRowColor;
  final Color? headerRowColor;
  final EdgeInsetsGeometry? rowPadding;
  final EdgeInsetsGeometry? headerRowPadding;
  final double expandHeightPadding;
  final double expandWidthPadding;
  final double space;
  final BorderSide? rowDivider;
  final BorderSide? aroundBorder;
  final bool utilityAtEnd;
  final bool expandIconFirst;
  final TextStyle? headerDefaultTextStyle;
  final TextStyle? expandHeaderDefaultTextStyle;
}
