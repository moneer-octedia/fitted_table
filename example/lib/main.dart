import 'package:flutter/material.dart';
import 'package:fitted_table/fitted_table.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PaginatedExpandableItemListExample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PaginatedExpandableItemListExample(),
    );
  }
}

class PaginatedExpandableItemListExample extends StatefulWidget {
  const PaginatedExpandableItemListExample({Key? key}) : super(key: key);

  @override
  State<PaginatedExpandableItemListExample> createState() =>
      _PaginatedExpandableItemListExampleState();
}

class _PaginatedExpandableItemListExampleState
    extends State<PaginatedExpandableItemListExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(64),
        child: DecoratedBox(
          decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.green),
          )),
          child: FittedTable(
            onTapDataRow: (user) {},
            evenDataRowColor: Colors.brown.withOpacity(0.6),
            oddDataRowColor: Colors.grey.withOpacity(0.6),
            dataRowPadding: const EdgeInsets.all(24),
            headerRowPadding: const EdgeInsets.symmetric(horizontal: 24,
            vertical: 12),
            headerRowColor: Colors.green,
            visibleNumberOfColumns: 3,
            future: (int pageKey, int pageSize) async {
              await Future.delayed(const Duration(milliseconds: 250));
              return List.generate(
                  pageSize, (index) => UserRecord(pageKey + index));
            },
            columns: [
              FittedTableColumn(
                width: 24,
                title: Text('#'),
              ),
              FittedTableColumn(
                title: Text('Motto'),
              ),
              FittedTableColumn(
                width: 100,
                title: Text('Name'),
              ),
            ],
            dataRowBuilder: (BuildContext context, user, int index) {
              return FittedTableRow(cells: [
                FittedTableCell(
                  content: ColoredBox(
                    color: Colors.blueGrey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${user.number}'),
                    ),
                  ),
                ),
                FittedTableCell(
                  content: ColoredBox(
                    color: Colors.blueGrey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${user.motto}'),
                    ),
                  ),
                ),
                FittedTableCell(
                  content: ColoredBox(
                    color: Colors.blueGrey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${user.name}'),
                    ),
                  ),
                )
              ]);
            },
          ),
        ),
      ),
    );
  }
}

class UserRecord {
  const UserRecord(this.number);

  final int number;

  String get name => 'user#$number';

  String get motto => number % 2 == 0
      ? 'I am very pleased that my user number is an even number'
      : 'I have an odd number';
}
