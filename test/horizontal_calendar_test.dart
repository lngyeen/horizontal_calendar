import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_calendar_widget/date_helper.dart';
import 'package:horizontal_calendar_widget/date_widget.dart';

void main() {
  final defaultLabelOrder = [
    LabelType.month,
    LabelType.date,
    LabelType.weekday,
  ];

  testWidgets(
      'Render widgets with date / month/ weekday by default formats if formats are provided not explicitly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        child: DateWidget(
          date: DateTime(2019, 11, 17),
          padding: const EdgeInsets.all(8),
          labelOrder: defaultLabelOrder,
        ),
        textDirection: TextDirection.ltr,
      ),
    );

    final date17 = find.text('17');
    expect(date17, findsOneWidget);
    final month11 = find.text('Nov');
    expect(month11, findsOneWidget);
    final week17 = find.text('Sun');
    expect(week17, findsOneWidget);
  });

  testWidgets(
    'Render widgets with dates / month / week day by default formats if formats are provided explicitly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          child: DateWidget(
            date: DateTime(2019, 11, 17),
            padding: const EdgeInsets.all(8),
            dateFormat: 'dd/MMM',
            monthFormat: 'MM',
            weekDayFormat: 'EEEE',
            labelOrder: defaultLabelOrder,
          ),
          textDirection: TextDirection.ltr,
        ),
      );

      final month11 = find.text('11');
      expect(month11, findsOneWidget);
      final date17 = find.text('17/Nov');
      expect(date17, findsOneWidget);
      final week17 = find.text('Sunday');
      expect(week17, findsOneWidget);
    },
  );

  testWidgets(
    'Default decoration should be applied to Date / month / weekday if not selected',
    (WidgetTester tester) async {
      const dateDecoration = BoxDecoration(
        color: Colors.blue,
      );

      await tester.pumpWidget(
        Directionality(
          child: DateWidget(
            date: DateTime(2019, 11, 17),
            padding: const EdgeInsets.all(8),
            dateFormat: null,
            monthFormat: null,
            weekDayFormat: null,
            defaultDecoration: dateDecoration,
            labelOrder: defaultLabelOrder,
          ),
          textDirection: TextDirection.ltr,
        ),
      );

      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is Container && widget.decoration == dateDecoration),
          findsOneWidget);
    },
  );

  testWidgets(
    'Selected decoration should be applied to Date / month / weekday is selected',
    (WidgetTester tester) async {
      const dateDecoration = BoxDecoration(
        color: Colors.blue,
      );

      await tester.pumpWidget(
        Directionality(
          child: DateWidget(
            date: DateTime(2019, 11, 17),
            padding: const EdgeInsets.all(8),
            dateFormat: null,
            monthFormat: null,
            weekDayFormat: null,
            selectedDecoration: dateDecoration,
            isSelected: true,
            labelOrder: defaultLabelOrder,
          ),
          textDirection: TextDirection.ltr,
        ),
      );

      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is Container && widget.decoration == dateDecoration),
          findsOneWidget);
    },
  );

  testWidgets(
    'Disabled decoration should be applied to Date / month / weekday if is disabled',
    (WidgetTester tester) async {
      const dateDecoration = BoxDecoration(
        color: Colors.blue,
      );

      const style = TextStyle(color: Colors.white);

      await tester.pumpWidget(
        Directionality(
          child: DateWidget(
            date: DateTime(2019, 11, 17),
            padding: const EdgeInsets.all(8),
            dateFormat: null,
            monthFormat: null,
            weekDayFormat: null,
            disabledDecoration: dateDecoration,
            isDisabled: true,
            dateTextStyle: style,
            labelOrder: defaultLabelOrder,
          ),
          textDirection: TextDirection.ltr,
        ),
      );

      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is Container && widget.decoration == dateDecoration),
          findsOneWidget);

      expect(
          find.byWidgetPredicate(
              (Widget widget) => widget is Text && widget.style == style),
          findsOneWidget);
    },
  );

  testWidgets(
    'Default Date with all properties',
    (WidgetTester tester) async {
      const defaultDecoration = BoxDecoration(
        color: Colors.blue,
      );

      const padding = EdgeInsets.symmetric(horizontal: 8);

      const monthStyle = TextStyle(color: Colors.white);
      const monthFormat = 'MM';

      const dateStyle = TextStyle(color: Colors.black);
      const dateFormat = 'dd/MM';

      const weekDayStyle = TextStyle(color: Colors.green);
      const weekDayFormat = 'EEE';

      await tester.pumpWidget(
        Directionality(
          child: DateWidget(
            date: DateTime(2019, 11, 17),
            padding: padding,
            dateFormat: dateFormat,
            dateTextStyle: dateStyle,
            monthFormat: monthFormat,
            monthTextStyle: monthStyle,
            weekDayFormat: weekDayFormat,
            weekDayTextStyle: weekDayStyle,
            defaultDecoration: defaultDecoration,
            labelOrder: defaultLabelOrder,
          ),
          textDirection: TextDirection.ltr,
        ),
      );

      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is Container && widget.decoration == defaultDecoration),
          findsOneWidget);

      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is Text &&
              widget.style == dateStyle &&
              widget.data == '17/11'),
          findsOneWidget);
      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is Text &&
              widget.style == monthStyle &&
              widget.data == '11'),
          findsOneWidget);

      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is Text &&
              widget.style == weekDayStyle &&
              widget.data == 'Sun'),
          findsOneWidget);
    },
  );

  testWidgets(
    'Lables should render as per provided order',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          child: DateWidget(
            date: DateTime(2019, 11, 17),
            padding: const EdgeInsets.all(8),
            labelOrder: const [
              LabelType.date,
              LabelType.month,
            ],
            dateTextStyle: null,
          ),
          textDirection: TextDirection.ltr,
        ),
      );

      expect(find.byWidgetPredicate((Widget widget) {
        if (widget is Column) {
          final children = widget.children;
          if (children.length < 2) {
            return false;
          }
          Text firstText = children[0] as Text;
          Text secondText = children[1] as Text;
          if (firstText.data == "17" && secondText.data == "Nov") {
            return true;
          }
        }
        return false;
      }), findsOneWidget);
    },
  );
}
