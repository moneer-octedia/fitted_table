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
        utilityAtEnd: true,
        expandIconFirst: true,
        headerDefaultTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        expandHeaderDefaultTextStyle: TextStyle(
          decoration: TextDecoration.underline
        ),
        rowDivider: BorderSide(width: 1.2, color: Colors.grey),
        aroundBorder: BorderSide(width: 1.2, color: Colors.grey),
        rowPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        headerRowPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        headerRowColor: Colors.blue,
      ),
      child: MaterialApp(
        title: 'FittedTableExample',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
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
    FittedColumn buildColumn(String text) {
      return FittedColumn(
        title: Text(
          text.toUpperCase(),
        ),
      );
    }

    FittedCell buildCell(String text) {
      return FittedCell(
        content: Text(text),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(64),
        child: FittedTable.builder(
            onTapRow: (user) {},
            visibleNumberOfColumns: 7,
            columns: [
              FittedColumn.utility(
                  width: 80,
                  expandIcon: const Icon(Icons.expand_more),
                  builder1: (value) {
                    return PopupMenuButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 18,
                      icon: const Icon(Icons.more_vert_outlined),
                      itemBuilder: (BuildContext context) {
                        buildPopupItem(IconData icon, String label) {
                          return Row(
                            children: [
                              Icon(
                                icon,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(label)
                            ],
                          );
                        }

                        return [
                          PopupMenuItem(
                              child: buildPopupItem(
                                  Icons.copy_outlined, 'Copy & Create')),
                          PopupMenuItem(
                              child:
                                  buildPopupItem(Icons.edit_outlined, 'Edit')),
                          PopupMenuItem(
                              child: buildPopupItem(
                                  Icons.delete_outline, 'Delete'))
                        ];
                      },
                    );
                  }),
              FittedColumn.tight(
                  title: Text(
                    'Number'.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  width: 72),
              buildColumn('Name'),
              buildColumn('Dish'),
              FittedColumn.flex(
                flex: 3,
                title: Text(
                  'Recipe'.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              buildColumn('Cuisine'),
              buildColumn('Status'),
              FittedColumn(
                title: Text(
                  'Extra Info'.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              FittedColumn(
                title: Text(
                  'Related Concepts'.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
            rowCount: 100,
            rowBuilder: (context, index) {
              final person = faker.person;
              final food = faker.food;
              final lorem = faker.lorem;
              return FittedTableRow(
                cells: [
                  const FittedCell.expand(),
                  buildCell('$index'),
                  buildCell(person.name()),
                  buildCell(food.dish()),
                  buildCell(lorem.sentences(index * 2).join(', ')),
                  buildCell(food.cuisine()),
                  buildCell(
                      ['Ready', 'Unavailable', 'Take out only'][index % 2]),
                  buildCell(lorem.sentences(index).join(', ')),
                  buildCell(lorem.words(index).join(', ')),
                ],
              );
            }),
      ),
    );
  }
}
