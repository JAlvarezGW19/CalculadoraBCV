import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';

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

  final List<Widget> _screens = const [
    CalculatorScreen(),
    ArithmeticCalculatorScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _initServices();
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
  }

  @override
  Widget build(BuildContext context) {
    // Safe lookup or fallback
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),
      floatingActionButton: const ScanFloatingButton(), // Clean!
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
                onTap: (i) {
                  setState(() => _currentIndex = i);
                  ref.read(activeTabProvider.notifier).state = i;
                },
              ),
              BottomNavItem(
                index: 1,
                currentIndex: _currentIndex,
                iconOutlined: Icons.calculate_outlined,
                iconFilled: Icons.calculate,
                label: l10n.calculatorScreen,
                onTap: (i) {
                  setState(() => _currentIndex = i);
                  ref.read(activeTabProvider.notifier).state = i;
                },
              ),
              const SizedBox(width: 48), // Space for FAB
              BottomNavItem(
                index: 2,
                currentIndex: _currentIndex,
                iconOutlined: Icons.history_outlined,
                iconFilled: Icons.history,
                label: l10n.history,
                onTap: (i) {
                  setState(() => _currentIndex = i);
                  ref.read(activeTabProvider.notifier).state = i;
                },
              ),
              BottomNavItem(
                index: 3,
                currentIndex: _currentIndex,
                iconOutlined: Icons.settings_outlined,
                iconFilled: Icons.settings,
                label: l10n.settings,
                onTap: (i) {
                  setState(() => _currentIndex = i);
                  ref.read(activeTabProvider.notifier).state = i;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
