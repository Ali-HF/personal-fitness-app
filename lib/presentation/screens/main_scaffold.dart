import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'today/today_screen.dart';
import 'plan/plan_screen.dart';
import 'progress/progress_screen.dart';
import 'settings/settings_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TodayScreen(),
    PlanScreen(),
    ProgressScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.dividerColor,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(PhosphorIconsRegular.barbell),
              activeIcon: Icon(PhosphorIconsFill.barbell),
              label: 'Today',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIconsRegular.calendarBlank),
              activeIcon: Icon(PhosphorIconsFill.calendarBlank),
              label: 'Plan',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIconsRegular.chartLineUp),
              activeIcon: Icon(PhosphorIconsFill.chartLineUp),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIconsRegular.gear),
              activeIcon: Icon(PhosphorIconsFill.gear),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

