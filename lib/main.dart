import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Date Formatting (Fast & Crucial)
  await initializeDateFormatting('es', null);

  // Initialize Google Mobile Ads (Fire and forget to not block startup)
  MobileAds.instance.initialize();

  // Run App immediately
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
