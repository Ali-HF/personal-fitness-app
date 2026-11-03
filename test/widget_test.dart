import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/presentation/screens/today/widgets/week_summary_row.dart';
import 'package:fitness_app/presentation/screens/today/widgets/countdown_card.dart';
import 'package:fitness_app/core/theme/app_theme.dart';

void main() {
  testWidgets('WeekSummaryRow widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: WeekSummaryRow(
            completedSessions: 4,
            plannedSessions: 6,
            totalKm: 18.5,
          ),
        ),
      ),
    );

    expect(find.text('4 / 6'), findsOneWidget);
    expect(find.text('18.5 km'), findsOneWidget);
    expect(find.text('Sessions Done'), findsOneWidget);
    expect(find.text('Distance Run'), findsOneWidget);
  });

  testWidgets('CountdownCard widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: CountdownCard(
            raceDateStr: '2027-01-03',
            test5kDateStr: '2026-12-17',
          ),
        ),
      ),
    );

    expect(find.text('days to Half Marathon'), findsOneWidget);
    expect(find.text('days to 5K Test'), findsOneWidget);
  });
}
