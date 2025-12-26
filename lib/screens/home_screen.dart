import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';

import '../theme/app_theme.dart';
import '../providers/bcv_provider.dart';
import '../widgets/add_rate_dialog.dart';
import '../widgets/scan_option_button.dart';
import '../widgets/bottom_nav_item.dart';
import '../services/notification_service.dart';
import '../services/background_service.dart';

import 'arithmetic_calculator_screen.dart';
import 'calculator_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'scan_screen.dart';

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

  Future<void> _checkPermissionsAndNavigate(VoidCallback navigateAction) async {
    final l10n = AppLocalizations.of(context)!;
    // Check current status
    var camStatus = await Permission.camera.status;

    // Simple check: if already granted, just go
    if (camStatus.isGranted) {
      navigateAction();
      return;
    }

    // Show explanation dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          title: Text(
            l10n.priceScanner,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            l10n.cameraPermissionText,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                l10n.cancel,
                style: const TextStyle(color: AppTheme.textSubtle),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.textAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(ctx); // Close dialog
                // Request Camera
                final newCamStatus = await Permission.camera.request();
                // Request Photos/Storage implies gallery access
                if (Platform.isAndroid) {
                  await Permission.photos.request();
                  await Permission.storage.request();
                }

                if (newCamStatus.isGranted) {
                  navigateAction();
                }
              },
              child: Text(l10n.allowAndContinue),
            ),
          ],
        ),
      );
    }
  }

  void _showScanOptions() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.whatToScan,
                style: AppTheme.subtitleStyle.copyWith(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ScanOptionButton(
                    label: l10n.amountUsd,
                    symbol: "\$",
                    color: AppTheme.textAccent,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _checkPermissionsAndNavigate(() {
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ScanScreen(
                              source: CurrencyType.usd,
                              target: CurrencyType.custom,
                            ),
                          ),
                        );
                      });
                    },
                  ),
                  ScanOptionButton(
                    label: l10n.amountEur,
                    symbol: "€",
                    color: AppTheme.textAccent,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _checkPermissionsAndNavigate(() {
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ScanScreen(
                              source: CurrencyType.eur,
                              target: CurrencyType.custom,
                            ),
                          ),
                        );
                      });
                    },
                  ),
                  ScanOptionButton(
                    label: l10n.ratePers,
                    symbol: "P",
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _handleCustomScan();
                    },
                  ),
                  ScanOptionButton(
                    label: l10n.amountVes,
                    symbol: "Bs",
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showTargetOptionsForVES();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Handle custom scan logic
  void _handleCustomScan({bool isInverse = false}) {
    final l10n = AppLocalizations.of(context)!;
    final customRates = ref.read(customRatesProvider);
    if (customRates.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          title: Text(
            l10n.noCustomRates,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            l10n.noCustomRatesDesc,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                l10n.cancel,
                style: const TextStyle(color: AppTheme.textSubtle),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final newRate = await showAddEditRateDialog(context, ref);
                if (newRate != null && mounted) {
                  _checkPermissionsAndNavigate(() {
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScanScreen(
                          source: CurrencyType.custom,
                          target: CurrencyType.custom,
                          isInverse: isInverse,
                          customRate: newRate,
                        ),
                      ),
                    );
                  });
                }
              },
              child: Text(
                l10n.createRate,
                style: const TextStyle(color: AppTheme.textAccent),
              ),
            ),
          ],
        ),
      );
      return;
    }
    // Show picker if exists
    showDialog(
      context: context,
      builder: (dialogCtx) => SimpleDialog(
        title: Text(l10n.chooseRate),
        children: [
          ...customRates.map(
            (r) => SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogCtx);
                _checkPermissionsAndNavigate(() {
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScanScreen(
                        source: CurrencyType.custom,
                        target: CurrencyType.custom,
                        isInverse: isInverse,
                        customRate: r,
                      ),
                    ),
                  );
                });
              },
              child: Text(r.name),
            ),
          ),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final newRate = await showAddEditRateDialog(
                context,
                ref,
              ); // Use stable 'context'
              if (newRate != null && mounted) {
                _checkPermissionsAndNavigate(() {
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScanScreen(
                        source: CurrencyType.custom,
                        target: CurrencyType.custom,
                        isInverse: isInverse,
                        customRate: newRate,
                      ),
                    ),
                  );
                });
              }
            },
            child: Text(
              l10n.newRate,
              style: const TextStyle(color: AppTheme.textAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showTargetOptionsForVES() {
    // Show second sheet: Convertir Bs a...
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.convertVesTo,
                style: AppTheme.subtitleStyle.copyWith(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ScanOptionButton(
                    label: l10n.usd,
                    symbol: "\$",
                    color: AppTheme.textAccent,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _checkPermissionsAndNavigate(() {
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ScanScreen(
                              source: CurrencyType.usd,
                              target: CurrencyType.custom,
                              isInverse: true,
                            ),
                          ),
                        );
                      });
                    },
                  ),
                  ScanOptionButton(
                    label: l10n.eur,
                    symbol: "€",
                    color: AppTheme.textAccent,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _checkPermissionsAndNavigate(() {
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ScanScreen(
                              source: CurrencyType.eur,
                              target: CurrencyType.custom,
                              isInverse: true,
                            ),
                          ),
                        );
                      });
                    },
                  ),
                  ScanOptionButton(
                    label: l10n.ratePers,
                    symbol: "P",
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _handleCustomScan(isInverse: true);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

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
    // Safe lookup or fallback (usually available after MaterialApp init)
    final l10n = AppLocalizations.of(context);

    // If l10n is null here it means we are too early or context is wrong,
    // but in a normal Scaffold > ConsumerStatefulWidget it should be fine.
    // We add a fallback just in case or assume ! null if we trust the tree.
    // For build method of the root screen, it might be safer to use defaults if null.
    // However, since MyApp sets locale, it should be ready.

    if (l10n == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: IndexedStack(
          // Use IndexedStack to preserve state of Calculator
          index: _currentIndex,
          children: _screens,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScanOptions(),
        backgroundColor: AppTheme.textAccent,
        elevation: 4.0,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.qr_code_scanner,
          color: AppTheme.background,
          size: 28,
        ),
      ),
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
