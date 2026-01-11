import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../providers/bcv_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../widgets/bottom_nav_item.dart';
import '../services/notification_service.dart';
import '../services/background_service.dart';
import '../utils/tutorial_keys.dart';

import '../widgets/home/scan_floating_button.dart'; // Extracted FAB
import '../providers/connectivity_provider.dart';

import 'arithmetic_calculator_screen.dart';
import 'calculator_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  final Set<int> _visitedTabs = {0}; // Track visited tabs
  Timer? _dateCheckTimer;
  bool _tutorialChecked = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _initServices();

    // Check for rate updates every minute while app is open
    _dateCheckTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _checkUpdates();
    });

    // Safety check: 30 seconds after launch, verify rates again.
    Timer(const Duration(seconds: 30), () {
      if (mounted) {
        _checkUpdates();
      }
    });
  }

  Future<void> _checkTutorial(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final bool seen = prefs.getBool('tutorial_v3_seen') ?? false;
    if (!seen) {
      // Trigger tutorial slightly delayed to ensure UI is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            ShowCaseWidget.of(context).startShowCase([
              TutorialKeys.currencyToggle,
              TutorialKeys.swapButton,
              TutorialKeys.ocrButton,
            ]);
            prefs.setBool('tutorial_v3_seen', true);
          }
        });
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lockOrientation();
  }

  void _lockOrientation() {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    if (!isTablet) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  void dispose() {
    _dateCheckTimer?.cancel();
    super.dispose();
  }

  void _checkUpdates() {
    // 1. Check for standard updates (Silent poller)
    ref.read(ratesProvider.notifier).checkForUpdates();

    // 2. Check for Date Change (Midnight Rollover)
    final ratesState = ref.read(ratesProvider);
    if (ratesState.hasValue) {
      final rates = ratesState.value!;
      if (rates.todayDate != null) {
        // Use Venezuela Time (UTC-4)
        final nowVenezuela = DateTime.now().toUtc().subtract(
          const Duration(hours: 4),
        );
        final today = DateTime(
          nowVenezuela.year,
          nowVenezuela.month,
          nowVenezuela.day,
        );
        final cachedToday = DateTime(
          rates.todayDate!.year,
          rates.todayDate!.month,
          rates.todayDate!.day,
        );

        if (today.isAfter(cachedToday)) {
          debugPrint("Date change detected, refreshing rates...");
          ref.read(ratesProvider.notifier).refresh();
        }
      }
    }
  }

  Future<void> _initServices() async {
    // Fire and forget heavy initializations AFTER UI is up
    MobileAds.instance.initialize();
    initializeDateFormatting('es', null);

    // Initialize Notifications
    final notificationService = NotificationService();
    await notificationService.init();
    await notificationService.requestPermissions();

    // Initialize Background Tasks
    try {
      await BackgroundService.initialize();
      await BackgroundService.registerPeriodicTask();
    } catch (e) {
      debugPrint("Background Initialization Failed: $e");
    }

    // Refresh widget with cached data immediately (so it's not empty)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(apiServiceProvider).refreshWidgetFromCache();
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      _visitedTabs.add(index);
    });
    ref.read(activeTabProvider.notifier).state = index;
  }

  // Helper to build lazy screens
  Widget _buildLazyScreen(int index, Widget screen) {
    if (_visitedTabs.contains(index)) {
      return screen;
    }
    return const SizedBox.shrink(); // Empty placeholder until visited
  }

  @override
  Widget build(BuildContext context) {
    // Safe lookup or fallback
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "Cargando recursos...",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
    // Listen for connectivity changes
    ref.listen<ConnectionStatus>(connectivityProvider, (previous, next) {
      if (previous != next) {
        if (next == ConnectionStatus.disconnected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(l10n.noInternetConnection),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (next == ConnectionStatus.connected &&
            previous == ConnectionStatus.disconnected) {
          // Force refresh logic when connection is restored
          ref.read(ratesProvider.notifier).refresh();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(l10n.internetRestored),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    });

    return ShowCaseWidget(
      builder: (context) {
        if (!_tutorialChecked) {
          _tutorialChecked = true;
          _checkTutorial(context);
        }
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                const CalculatorScreen(), // Always present (Index 0)
                _buildLazyScreen(1, const ArithmeticCalculatorScreen()),
                _buildLazyScreen(2, const HistoryScreen()),
                _buildLazyScreen(3, const SettingsScreen()),
              ],
            ),
          ),
          floatingActionButton: const ScanFloatingButton(),
          floatingActionButtonLocation: const _FixedCenterDockedFabLocation(),
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            color: AppTheme.cardBackground,
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  BottomNavItem(
                    index: 0,
                    currentIndex: _currentIndex,
                    iconOutlined: Icons.dashboard_outlined,
                    iconFilled: Icons.dashboard,
                    label: l10n.homeScreen,
                    onTap: _onTabSelected,
                  ),
                  BottomNavItem(
                    index: 1,
                    currentIndex: _currentIndex,
                    iconOutlined: Icons.calculate_outlined,
                    iconFilled: Icons.calculate,
                    label: l10n.calculatorScreen,
                    onTap: _onTabSelected,
                  ),
                  const SizedBox(width: 48), // Space for FAB
                  BottomNavItem(
                    index: 2,
                    currentIndex: _currentIndex,
                    iconOutlined: Icons.history_outlined,
                    iconFilled: Icons.history,
                    label: l10n.history,
                    onTap: _onTabSelected,
                  ),
                  BottomNavItem(
                    index: 3,
                    currentIndex: _currentIndex,
                    iconOutlined: Icons.settings_outlined,
                    iconFilled: Icons.settings,
                    label: l10n.settings,
                    onTap: _onTabSelected,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FixedCenterDockedFabLocation extends FloatingActionButtonLocation {
  const _FixedCenterDockedFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX =
        (scaffoldGeometry.scaffoldSize.width -
            scaffoldGeometry.floatingActionButtonSize.width) /
        2.0;
    final double fabY =
        scaffoldGeometry.contentBottom -
        scaffoldGeometry.floatingActionButtonSize.height / 2.0;
    return Offset(fabX, fabY);
  }
}
