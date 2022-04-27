import 'package:flutter/material.dart';
import 'package:horizontal_calendar_widget/date_helper.dart';
import 'package:horizontal_calendar_widget/horizontal_calendar.dart';
import 'package:intl/intl.dart';

import 'components/components.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Horizontal Calendar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Horizontal Calendar Demo')),
        body: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: DemoWidget(),
        ),
      ),
    );
  }
}

const labelMonth = 'Month';
const labelDate = 'Date';
const labelWeekDay = 'Week Day';

class DemoWidget extends StatefulWidget {
  const DemoWidget({
    Key? key,
  }) : super(key: key);

  @override
  _DemoWidgetState createState() => _DemoWidgetState();
}

class _DemoWidgetState extends State<DemoWidget> {
  static const int days = 30;

  late DateTime firstDate = toDateMonthYear(DateTime.now());
  late DateTime lastDate =
      toDateMonthYear(firstDate.add(const Duration(days: days - 1)));
  String dateFormat = 'dd';
  String monthFormat = 'MMM';
  String weekDayFormat = 'EEE';
  List<String> order = [labelMonth, labelDate, labelWeekDay];
  bool forceRender = false;

  Color defaultDecorationColor = Colors.transparent;
  BoxShape defaultDecorationShape = BoxShape.rectangle;
  bool isCircularRadiusDefault = true;

  Color selectedDecorationColor = Colors.green;
  BoxShape selectedDecorationShape = BoxShape.rectangle;
  bool isCircularRadiusSelected = true;

  Color disabledDecorationColor = Colors.grey;
  BoxShape disabledDecorationShape = BoxShape.rectangle;
  bool isCircularRadiusDisabled = true;

  int minSelectedDateCount = 1;
  int maxSelectedDateCount = 1;
  late RangeValues selectedDateCount = RangeValues(
    minSelectedDateCount.toDouble(),
    maxSelectedDateCount.toDouble(),
  );

  late List<DateTime> initialSelectedDates =
      feedInitialSelectedDates(minSelectedDateCount, days);

  @override
  void initState() {
    super.initState();
  }

  List<DateTime> feedInitialSelectedDates(int target, int calendarDays) {
    List<DateTime> selectedDates = [];

    for (int i = 0; i < calendarDays; i++) {
      if (selectedDates.length == target) {
        break;
      }
      DateTime date = firstDate.add(Duration(days: i));
      if (date.weekday != DateTime.sunday) {
        selectedDates.add(date);
      }
    }

    return selectedDates;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 16),
        HorizontalCalendar(
          key: forceRender ? UniqueKey() : const Key('Calendar'),
          height: 120,
          padding: const EdgeInsets.all(22),
          firstDate: firstDate,
          lastDate: lastDate,
          dateFormat: dateFormat,
          weekDayFormat: weekDayFormat,
          monthFormat: monthFormat,
          defaultDecoration: BoxDecoration(
            color: defaultDecorationColor,
            shape: defaultDecorationShape,
            borderRadius: defaultDecorationShape == BoxShape.rectangle &&
                    isCircularRadiusDefault
                ? BorderRadius.circular(8)
                : null,
          ),
          selectedDecoration: BoxDecoration(
            color: selectedDecorationColor,
            shape: selectedDecorationShape,
            borderRadius: selectedDecorationShape == BoxShape.rectangle &&
                    isCircularRadiusSelected
                ? BorderRadius.circular(8)
                : null,
          ),
          disabledDecoration: BoxDecoration(
            color: disabledDecorationColor,
            shape: disabledDecorationShape,
            borderRadius: disabledDecorationShape == BoxShape.rectangle &&
                    isCircularRadiusDisabled
                ? BorderRadius.circular(8)
                : null,
          ),
          isDateDisabled: (date) => date.weekday == DateTime.sunday,
          labelOrder: order.map(toLabelType).toList(),
          minSelectedDateCount: minSelectedDateCount,
          maxSelectedDateCount: maxSelectedDateCount,
          initialSelectedDates: initialSelectedDates,
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView(
            children: <Widget>[
              const Header(headerText: 'Date Ranges'),
              Row(
                children: <Widget>[
                  Expanded(
                    child: PropertyLabel(
                      label: 'First Date',
                      value: Text(DateFormat('dd/MM/yyyy').format(firstDate)),
                      onTap: () async {
                        final date = await datePicker(context, firstDate);
                        if (date == null) {
                          return;
                        }

                        if (lastDate.isBefore(date)) {
                          showMessage('First Date cannot be after Last Date');
                          return;
                        }

                        int min = minSelectedDateCount;
                        if (!isRangeValid(date, lastDate, min)) {
                          showMessage(
                            "Date range is too low to set this configuration",
                          );
                          return;
                        }

                        setState(() {
                          forceRender = true;
                          dateRangeChange(date, lastDate);
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: PropertyLabel(
                      label: 'Last Date',
                      value: Text(DateFormat('dd/MM/yyyy').format(lastDate)),
                      onTap: () async {
                        final date = await datePicker(context, lastDate);
                        if (date == null) {
                          return;
                        }

                        if (firstDate.isAfter(date)) {
                          showMessage(
                            'Last Date cannot be before First Date',
                          );
                          return;
                        }

                        int min = minSelectedDateCount;
                        if (!isRangeValid(firstDate, date, min)) {
                          showMessage(
                            "Date range is too low to set this configuration",
                          );
                          return;
                        }

                        setState(() {
                          forceRender = true;
                          dateRangeChange(firstDate, date);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const Header(headerText: 'Date Selection'),
              PropertyLabel(
                label:
                    'Min-Max Selectable Dates ($minSelectedDateCount - $maxSelectedDateCount)',
                value: CustomRangeSlider(
                  range: selectedDateCount,
                  min: 0,
                  max: 15,
                  onRangeSet: (newRange) {
                    selectedDateCount = newRange;
                  },
                ),
              ),
              TextButton(
                child: const Text('Update'),
                onPressed: () {
                  setState(() {
                    int min = selectedDateCount.start.toInt();
                    if (!isRangeValid(firstDate, lastDate, min)) {
                      showMessage(
                        "Date range is too low to set this configuration",
                      );
                      return;
                    }

                    minSelectedDateCount = selectedDateCount.start.toInt();
                    maxSelectedDateCount = selectedDateCount.end.toInt();
                    initialSelectedDates = feedInitialSelectedDates(
                      minSelectedDateCount,
                      daysCount(firstDate, lastDate),
                    );
                    showMessage("Updated");
                  });
                },
              ),
              const Header(headerText: 'Formats'),
              PropertyLabel(
                label: 'Date Format',
                value: DropDownProperty<String>(
                  hint: 'Select Date Format',
                  value: dateFormat,
                  options: const ['dd', 'dd/MM'],
                  onChange: (format) {
                    setState(() {
                      forceRender = false;
                      dateFormat = format;
                    });
                  },
                ),
              ),
              PropertyLabel(
                label: 'Month Format',
                value: DropDownProperty<String>(
                  hint: 'Select Month Format',
                  value: monthFormat,
                  options: const [
                    'MM',
                    'MMM',
                  ],
                  onChange: (format) {
                    setState(() {
                      forceRender = false;
                      monthFormat = format;
                    });
                  },
                ),
              ),
              PropertyLabel(
                label: 'WeekDay Format',
                value: DropDownProperty<String>(
                  hint: 'Select Weekday Format',
                  value: weekDayFormat,
                  options: const ['EEE', 'EEEE'],
                  onChange: (format) {
                    setState(() {
                      forceRender = false;
                      weekDayFormat = format;
                    });
                  },
                ),
              ),
              const Header(headerText: 'Labels'),
              PropertyLabel(
                label: 'Label Orders (Drag & Drop to reorder)',
                value: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        height: 200,
                        width: 150,
                        child: ReorderableListView(
                          children: order
                              .map(
                                (listItem) => Align(
                                  key: Key(listItem),
                                  heightFactor: 1,
                                  alignment: Alignment.centerLeft,
                                  child: Chip(
                                    onDeleted: () => listItem != labelDate
                                        ? setState(() {
                                            forceRender = false;
                                            order.remove(listItem);
                                          })
                                        : null,
                                    deleteIcon: listItem != labelDate
                                        ? const Icon(Icons.cancel)
                                        : null,
                                    label: Text(listItem),
                                  ),
                                ),
                              )
                              .toList(),
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              forceRender = false;
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final item = order.removeAt(oldIndex);
                              order.insert(newIndex, item);
                            });
                          },
                        ),
                      ),
                      TextButton(
                        child: const Text('Add Labels'),
                        onPressed: () {
                          setState(() {
                            forceRender = false;
                            if (!order.contains(labelMonth)) {
                              order.add(labelMonth);
                            }
                            if (!order.contains(labelWeekDay)) {
                              order.add(labelWeekDay);
                            }
                          });
                        },
                      )
                    ],
                  ),
                ),
              ),
              const Header(headerText: 'Default Decoration'),
              DecorationBuilder(
                decorationShape: defaultDecorationShape,
                onSelectShape: (value) {
                  setState(() {
                    forceRender = false;
                    defaultDecorationShape = value;
                  });
                },
                isCircularRadius: isCircularRadiusDefault,
                onCircularRadiusChange: (isSelected) {
                  setState(
                    () {
                      isCircularRadiusDefault = isSelected ?? false;
                    },
                  );
                },
                color: defaultDecorationColor,
                onColorChange: (value) {
                  setState(() {
                    forceRender = false;
                    defaultDecorationColor = value;
                  });
                },
              ),
              const Header(headerText: 'Selected Decoration'),
              DecorationBuilder(
                decorationShape: selectedDecorationShape,
                onSelectShape: (value) {
                  setState(() {
                    forceRender = false;
                    selectedDecorationShape = value;
                  });
                },
                isCircularRadius: isCircularRadiusSelected,
                onCircularRadiusChange: (isSelected) {
                  setState(
                    () {
                      forceRender = false;
                      isCircularRadiusSelected = isSelected ?? false;
                    },
                  );
                },
                color: selectedDecorationColor,
                onColorChange: (value) {
                  setState(() {
                    forceRender = false;
                    selectedDecorationColor = value;
                  });
                },
              ),
              const Header(headerText: 'Disabled Decoration'),
              DecorationBuilder(
                decorationShape: disabledDecorationShape,
                onSelectShape: (value) {
                  setState(() {
                    forceRender = false;
                    disabledDecorationShape = value;
                  });
                },
                isCircularRadius: isCircularRadiusDisabled,
                onCircularRadiusChange: (isSelected) {
                  setState(
                    () {
                      forceRender = false;
                      isCircularRadiusDisabled = isSelected ?? false;
                    },
                  );
                },
                color: disabledDecorationColor,
                onColorChange: (value) {
                  setState(() {
                    forceRender = false;
                    disabledDecorationColor = value;
                  });
                },
              )
            ],
          ),
        )
      ],
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool isRangeValid(DateTime first, DateTime last, int minSelection) {
    int availableDays = availableDaysCount(
      getDateList(first, last),
      [DateTime.sunday],
    );

    return availableDays >= minSelection;
  }

  int availableDaysCount(List<DateTime> dates, List<int> disabledDays) =>
      dates.where((date) => !disabledDays.contains(date.weekday)).length;

  void dateRangeChange(DateTime first, DateTime last) {
    firstDate = first;
    lastDate = last;
    initialSelectedDates = feedInitialSelectedDates(
      minSelectedDateCount,
      daysCount(first, last),
    );
    selectedDateCount = RangeValues(
      minSelectedDateCount.toDouble(),
      maxSelectedDateCount.toDouble(),
    );
  }
}

Future<DateTime?> datePicker(
  BuildContext context,
  DateTime initialDate,
) async {
  final selectedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime.now().subtract(
      const Duration(days: 365),
    ),
    lastDate: DateTime.now().add(
      const Duration(days: 365),
    ),
  );
  if (selectedDate == null) {
    return null;
  }
  return toDateMonthYear(selectedDate);
}

LabelType toLabelType(String label) {
  LabelType type = LabelType.date;
  switch (label) {
    case labelMonth:
      type = LabelType.month;
      break;
    case labelDate:
      type = LabelType.date;
      break;
    case labelWeekDay:
      type = LabelType.weekday;
      break;
  }
  return type;
}

String fromLabelType(LabelType label) {
  String labelString;
  switch (label) {
    case LabelType.month:
      labelString = labelMonth;
      break;
    case LabelType.date:
      labelString = labelDate;
      break;
    case LabelType.weekday:
      labelString = labelWeekDay;
      break;
  }
  return labelString;
}
