import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/database_helper.dart';
import 'data/datasources/plan_repository.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local SQLite database and load plan data
  await DatabaseHelper.instance.database;
  await PlanRepository.instance.load();

  runApp(
    const ProviderScope(
      child: FitnessApp(),
    ),
  );
}

class FitnessApp extends ConsumerWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider);
    final themeMode = ref.read(settingsProvider.notifier).currentThemeMode;

    return MaterialApp(
      title: 'Fitness App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        // When running on desktop/laptop browser, wrap in a simulated mobile device frame
        final width = MediaQuery.of(context).size.width;
        if (width > 500) {
          return Scaffold(
            backgroundColor: const Color(0xFF141414),
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420, maxHeight: 900),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                  border: Border.all(color: const Color(0xFF333333), width: 3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(33),
                  child: child,
                ),
              ),
            ),
          );
        }
        return child ?? const SizedBox.shrink();
      },
      home: const MainScaffold(),
    );
  }
}
