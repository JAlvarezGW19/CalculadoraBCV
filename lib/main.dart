import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

import 'services/background_service.dart';
import 'services/notification_service.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Date Formatting
  await initializeDateFormatting('es', null);

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions(); // Request on launch

  // Initialize Background Tasks
  await BackgroundService.initialize();
  await BackgroundService.registerPeriodicTask();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora BCV',
      theme: AppTheme.themeData,
      home: const HomeScreen(),
    );
  }
}
