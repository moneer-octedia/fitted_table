import 'package:flutter/material.dart';
import 'package:fitted_table/fitted_table.dart';

const loremIpsum =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut id tellus ut enim lobortis aliquam. Quisque blandit a tortor quis molestie. Curabitur rutrum porta ligula, non porta massa mollis a. Phasellus porttitor, eros at rutrum ullamcorper, mauris purus ultricies mi, sed consectetur tellus libero rutrum felis. Aliquam vel leo iaculis orci dictum mattis. Integer tristique volutpat quam id semper. In tincidunt vel massa at aliquet. Quisque sit amet turpis et turpis interdum tempor. Duis eu turpis lectus. Integer hendrerit tempus sollicitudin. Phasellus lacinia urna in vehicula consectetur. Curabitur sit amet pulvinar ante. Vivamus laoreet nibh sit amet fermentum sodales. Praesent quis mauris imperdiet, placerat erat eget, convallis mauris. Sed nec lorem nisl. Curabitur viverra porta imperdiet. ';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedTableTheme(
      fittedTableThemeData: FittedTableThemeData(
        expandTitleStyle:
            TextStyle(color: Colors.red),
        evenRowColor: Colors.brown.withOpacity(0.6),
        oddRowColor: Colors.grey.withOpacity(0.6),
        rowPadding: const EdgeInsets.all(24),
        headerRowPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        headerRowColor: Colors.green,
      ),
      child: MaterialApp(
        title: 'FittedTableExample',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
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
              visibleNumberOfColumns: 3,
              columns: [
                FittedColumn.expand(),
                FittedColumn(
                  title: Text('#'),
                ),
                FittedColumn(
                  title: Text('#'),
                ),
                FittedColumn.flex(
                  flex: 10,
                  title: Text('Motto'),
                ),
                FittedColumn.tight(
                  width: 100,
                  title: Text('Name'),
                ),
              ],
              rowCount: 100,
              rowBuilder: (context, index) {
                return FittedTableRow(
                    cells: [
                      FittedCell.expand(
                        icon: ColoredBox(
                            color: Colors.blueGrey,
                            child: Icon(Icons.add_circle_outline)),
                      ),
                      FittedCell(
                        content: ColoredBox(
                          color: Colors.blueGrey,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                '$index$index$index$index$index$index$index$index$index$index$index$index$index'),
                          ),
                        ),
                      ),
                      FittedCell(
                        content: ColoredBox(
                          color: Colors.blueGrey,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                '$index$index$index$index$index$index$index$index$index$index$index$index$index'),
                          ),
                        ),
                      ),
                      FittedCell(
                        content: ColoredBox(
                          color: Colors.blueGrey,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(loremIpsum),
                          ),
                        ),
                      ),
                      FittedCell(
                        content: ColoredBox(
                          color: Colors.blueGrey,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('same name'),
                          ),
                        ),
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
        // child: FittedTable.paginated(
        //   onTapDataRow: (user) {},
        //   visibleNumberOfColumns: 3,
        //   future: (int pageKey, int pageSize) async {
        //     await Future.delayed(const Duration(milliseconds: 250));
        //     return List.generate(
        //         pageSize, (index) => UserRecord(pageKey + index));
        //   },
        //   columns: [
        //     ExpandFittedTableColumn(),
        //     FittedTableColumn(
        //       title: Text('#'),
        //     ),
        //     FittedTableColumn(
        //       title: Text('Motto'),
        //     ),
        //     FittedTableColumn(
        //       width: 100,
        //       title: Text('Name'),
        //     ),
        //   ],
        //   dataRowBuilder: (BuildContext context, user, int index) {
        //     return FittedTableRow(cells: [
        //       ExpandFittedTableCell(
        //         icon: ColoredBox(
        //             color: Colors.blueGrey,
        //             child: Icon(Icons.add_circle_outline)),
        //       ),
        //       FittedTableCell(
        //         content: ColoredBox(
        //           color: Colors.blueGrey,
        //           child: Padding(
        //             padding: const EdgeInsets.all(8.0),
        //             child: Text('${user.number}'),
        //           ),
        //         ),
        //       ),
        //       FittedTableCell(
        //         content: ColoredBox(
        //           color: Colors.blueGrey,
        //           child: Padding(
        //             padding: const EdgeInsets.all(8.0),
        //             child: Text('${user.motto}'),
        //           ),
        //         ),
        //       ),
        //       FittedTableCell(
        //         content: ColoredBox(
        //           color: Colors.blueGrey,
        //           child: Padding(
        //             padding: const EdgeInsets.all(8.0),
        //             child: Text('${user.name}'),
        //           ),
        //         ),
        //       )
        //     ]);
        //   },
        // ),
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
