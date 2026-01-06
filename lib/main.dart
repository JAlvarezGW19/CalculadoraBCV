import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/language_provider.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Lock orientation to portrait (fire and forget to not block UI)
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // ... existing code ...

    // Initialize Date Formatting (Fire and forget)
    // We start this ASAP but don't wait for it to render the first frame
    initializeDateFormatting('es', null).catchError((e) {
      debugPrint("DateFormatting Error: $e");
      return null;
    });

    // Initialize Google Mobile Ads (Wrapped to prevent hangs)
    // Fire and forget, don't await to avoid blocking startup
    MobileAds.instance.initialize();

    // Explicitly remove splash screen to prevent hanging
    // try {
    //   FlutterNativeSplash.remove();
    // } catch (e) {
    //   debugPrint("Error removing splash: $e");
    // }

    // Run App immediately
    runApp(const ProviderScope(child: MyApp()));
  } catch (e, stack) {
    debugPrint("Startup Error: $e");
    debugPrint(stack.toString());
    runApp(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFF0A192F),
          body: Center(
            child: Text(
              "Error Critical al Iniciar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    AppTheme.currentLocale = locale; // Update theme locale

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora BCV',
      theme: AppTheme.themeData,
      locale: locale, // Dynamic locale
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: (locales, supportedLocales) {
        // 1. If user selected a specific language in app, 'locale' (line 46) is not null,
        // so this callback might not even be used or 'locale' takes precedence.
        // Actually, 'locale' property takes precedence. This callback is for system default.

        if (locales == null || locales.isEmpty) {
          return supportedLocales.first;
        }

        // 2. Check if any of the user's system locales are supported
        for (final locale in locales) {
          for (final supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) {
              return supported;
            }
          }
        }

        // 3. If none match, return English
        return const Locale('en');
      },
      home: const HomeScreen(),
    );
  }
}
