// Smoke test: app khởi động được ở chế độ offline-first (không Firebase)
// và hiển thị thanh điều hướng chính với 5 tab.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vipinfo/main.dart';
import 'package:vipinfo/providers/habit_provider.dart';
import 'package:vipinfo/providers/pomodoro_provider.dart';
import 'package:vipinfo/providers/task_provider.dart';
import 'package:vipinfo/providers/theme_provider.dart';
import 'package:vipinfo/screens/main_navigation.dart';

void main() {
  testWidgets('App khởi động và hiển thị 5 tab điều hướng', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider(create: (_) => TaskProvider(prefs)),
          ChangeNotifierProvider(create: (_) => PomodoroProvider()),
          ChangeNotifierProvider(create: (_) => HabitProvider(prefs)),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(MainNavigation), findsOneWidget);
    expect(find.text('Tasks'), findsWidgets);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Pomodoro'), findsWidgets);
    expect(find.text('Habits'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });
}
