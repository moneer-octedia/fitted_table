import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fitted_table/fitted_table.dart';

void main() {
  const numberOfColumns = 10;
  const double screenWidth = 1000.0;

  testWidgets('FittedColumn columns alone', (tester) async {
    late BuildContext context;

    final fittedTable = FittedTable(
        space: 0,
        visibleNumberOfColumns: numberOfColumns,
        columns: List.generate(numberOfColumns,
            (index) => const FittedColumn(title: Text('title'))),
        rows: [
          FittedTableRow(
              cells: List.generate(numberOfColumns,
                  (index) => const FittedCell(content: Text('text'))))
        ]);

    final widgetToJustGetContext = FittedTableTheme(
      fittedTableThemeData:
          const FittedTableThemeData(rowPadding: EdgeInsets.zero),
      child: Builder(
        builder: (inContext) {
          context = inContext;
          return const SizedBox();
        },
      ),
    );

    await tester.pumpWidget(widgetToJustGetContext);

    final evenColumnWidth = fittedTable.resolveEvenColumnWidth(
        context, const BoxConstraints.tightFor(width: screenWidth));

    expect(evenColumnWidth, screenWidth / numberOfColumns);
  });

  testWidgets('FittedColumn.tight and FittedColumn columns', (tester) async {
    const double columnWidth = 10.0;
    const int numberOfTightColumns = numberOfColumns - 5;
    late BuildContext context;

    final fittedTable = FittedTable(
        space: 0,
        visibleNumberOfColumns: numberOfColumns,
        columns: List.generate(
            numberOfColumns,
            (index) => index < numberOfTightColumns
                ? const FittedColumn.tight(
                    width: columnWidth, title: Text('title'))
                : const FittedColumn(title: Text('title'))),
        rows: [
          FittedTableRow(
              cells: List.generate(numberOfColumns,
                  (index) => const FittedCell(content: Text('text'))))
        ]);

    final widgetToJustGetContext = FittedTableTheme(
      fittedTableThemeData:
          const FittedTableThemeData(rowPadding: EdgeInsets.zero),
      child: Builder(
        builder: (inContext) {
          context = inContext;
          return const SizedBox();
        },
      ),
    );

    await tester.pumpWidget(widgetToJustGetContext);

    final evenColumnWidth = fittedTable.resolveEvenColumnWidth(
        context, const BoxConstraints.tightFor(width: screenWidth));

    const expectedEvenValueWidth = (screenWidth / numberOfColumns) -
        ((columnWidth * numberOfTightColumns) /
            (numberOfColumns - numberOfTightColumns));
    expect(evenColumnWidth, expectedEvenValueWidth);
  });
}
