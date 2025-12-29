import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../providers/bcv_provider.dart';
import '../widgets/bottom_nav_item.dart';
import '../services/notification_service.dart';
import '../services/background_service.dart';

import '../widgets/home/scan_floating_button.dart'; // Extracted FAB

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

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _initServices();

    // Check for date rollover every minute while app is open
    _dateCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkForDateChange();
    });
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

  void _checkForDateChange() {
    final ratesState = ref.read(ratesProvider);
    if (ratesState.hasValue) {
      final rates = ratesState.value!;
      if (rates.todayDate != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final cachedToday = DateTime(
          rates.todayDate!.year,
          rates.todayDate!.month,
          rates.todayDate!.day,
        );

        // If cached "Today" is older than real "Today", refresh!
        // Example: Cache says "Today is Friday". Real is "Monday".
        // The provider rollover logic will see the "Tomorrow" (Monday) and promote it to Today.
        if (today.isAfter(cachedToday)) {
          debugPrint("Date change detected, refreshing rates...");
          ref.read(ratesProvider.notifier).refresh();
        }
      }
    }
  }

  Future<void> _initServices() async {
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
      // Added initial check on startup too in case it was opened exactly after midnight
      _checkForDateChange();
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

    return Scaffold(
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
  }
}
