import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

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
          title: const Text(
            "Escáner de Precios",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Esta herramienta utiliza la cámara para detectar precios y convertirlos en tiempo real.\n\n"
            "Para funcionar, necesita acceso a la Cámara y a la Galería (para seleccionar imágenes).",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: AppTheme.textSubtle),
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
              child: const Text("Permitir y Continuar"),
            ),
          ],
        ),
      );
    }
  }

  void _showScanOptions() {
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
                "¿Qué vas a escanear?",
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
                    label: "Monto USD",
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
                    label: "Monto EUR",
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
                    label: "Tasa Pers.",
                    symbol: "P",
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _handleCustomScan();
                    },
                  ),
                  ScanOptionButton(
                    label: "Monto Bs.",
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
    final customRates = ref.read(customRatesProvider);
    if (customRates.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          title: const Text(
            "Sin tasas personalizadas",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Necesitas agregar una tasa personalizada para usar esta función.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: AppTheme.textSubtle),
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
              child: const Text(
                "Crear Tasa",
                style: TextStyle(color: AppTheme.textAccent),
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
        title: const Text("Elige una tasa"),
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
            child: const Text(
              "Nueva Tasa...",
              style: TextStyle(color: AppTheme.textAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showTargetOptionsForVES() {
    // Show second sheet: Convertir Bs a...
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
                "Convertir Bolívares a...",
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
                    label: "Dólares",
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
                    label: "Euros",
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
                    label: "Pers.",
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
                label: "Inicio",
                onTap: (i) => setState(() => _currentIndex = i),
              ),
              BottomNavItem(
                index: 1,
                currentIndex: _currentIndex,
                iconOutlined: Icons.calculate_outlined,
                iconFilled: Icons.calculate,
                label: "Calculadora",
                onTap: (i) => setState(() => _currentIndex = i),
              ),
              const SizedBox(width: 48), // Space for FAB
              BottomNavItem(
                index: 2,
                currentIndex: _currentIndex,
                iconOutlined: Icons.history_outlined,
                iconFilled: Icons.history,
                label: "Historial",
                onTap: (i) => setState(() => _currentIndex = i),
              ),
              BottomNavItem(
                index: 3,
                currentIndex: _currentIndex,
                iconOutlined: Icons.settings_outlined,
                iconFilled: Icons.settings,
                label: "Ajustes",
                onTap: (i) => setState(() => _currentIndex = i),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
