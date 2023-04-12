import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:fitted_table/fitted_table.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedTableTheme(
      fittedTableThemeData: FittedTableThemeData(
        space: 8,
        rowDivider: BorderSide(width: 1.2, color: Colors.grey),
        rowPadding: const EdgeInsets.symmetric(vertical: 12),
        headerRowPadding: const EdgeInsets.symmetric(vertical: 12),
        headerRowColor: Colors.teal,
      ),
      child: MaterialApp(
        title: 'FittedTableExample',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.teal,
        ),
        home: const FittedTableExample(),
      ),
    );
  }
}

class FittedTableExample extends StatefulWidget {
  const FittedTableExample({Key? key}) : super(key: key);

  @override
  State<FittedTableExample> createState() => _FittedTableExampleState();
}

class _FittedTableExampleState extends State<FittedTableExample> {
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
          child: FittedTable.builder(
              onTapRow: (user) {},
              visibleNumberOfColumns: 6,
              columns: [
                FittedColumn.expand(),
                FittedColumn(
                  title: Text('Number'),
                ),
                FittedColumn(
                  title: Text('Name'),
                ),
                FittedColumn(
                  title: Text('Dish'),
                ),
                FittedColumn.flex(
                  flex: 3,
                  title: Text('Motto'),
                ),
                FittedColumn.tight(
                  width: 100,
                  title: Text('Comments'),
                ),
                FittedColumn.tight(
                  width: 100,
                  title: Text('Status'),
                ),
              ],
              rowCount: 100,
              rowBuilder: (context, index) {
                return FittedTableRow(
                    cells: [
                      FittedCell.expand(
                        icon: Icon(Icons.add_circle_outline),
                      ),
                      FittedCell(
                        content: Text('$index'),
                      ),
                      FittedCell(
                        content: Text(faker.person.name()),
                      ),
                      FittedCell(
                        content: Text(faker.food.dish()),
                      ),
                      FittedCell(
                        content:
                            Text(faker.lorem.sentences(index * 10).join(', ')),
                      ),
                      FittedCell(
                        content: Text('Cooked'),
                      ),
                      FittedCell(
                        content: Text('same name'),
                      )
                    ],
                    expandAction: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton(onPressed: () {}, child: Text('Edit'))
                        ],
                      ),
                    ));
              }),
        ),
      ),
    );
  }
}
