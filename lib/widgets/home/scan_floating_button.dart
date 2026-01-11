import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/bcv_provider.dart';
import '../../screens/scan_screen.dart';
import '../scan_option_button.dart';
import '../add_rate_dialog.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';

import 'package:showcaseview/showcaseview.dart';
import '../../utils/tutorial_keys.dart';
import '../common/tutorial_tooltip.dart';

class ScanFloatingButton extends ConsumerWidget {
  const ScanFloatingButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Safety check for l10n, though usually available.
    // If not, we just return the FAB (Showcase handles null strings? No).
    // But l10n shouldn't be null here.

    final fab = FloatingActionButton(
      onPressed: () => _showScanOptions(context, ref),
      backgroundColor: AppTheme.textAccent,
      elevation: 4.0,
      shape: const CircleBorder(),
      child: const Icon(
        Icons.qr_code_scanner,
        color: AppTheme.background,
        size: 28,
      ),
    );

    if (l10n == null) return fab;

    return Showcase.withWidget(
      key: TutorialKeys.ocrButton,
      height: 200,
      width: 280,
      container: TutorialTooltip(
        title: l10n.tutorialThreeTitle,
        description: l10n.tutorialThreeDesc,
        step: 3,
        totalSteps: 3,
        onFinished: () {
          ShowCaseWidget.of(context).dismiss();
        },
      ),
      child: fab,
    );
  }

  void _showScanOptions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
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
                        _checkPermissionsAndNavigate(context, () {
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
                        _checkPermissionsAndNavigate(context, () {
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
                        _handleCustomScan(context, ref);
                      },
                    ),
                    ScanOptionButton(
                      label: l10n.amountVes,
                      symbol: "Bs",
                      color: Colors.blueAccent,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _showTargetOptionsForVES(context, ref);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _checkPermissionsAndNavigate(
    BuildContext context,
    VoidCallback navigateAction,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    // Check current status
    var camStatus = await Permission.camera.status;

    if (camStatus.isGranted) {
      if (context.mounted) navigateAction();
      return;
    }

    if (context.mounted) {
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
                Navigator.pop(ctx);
                final newCamStatus = await Permission.camera.request();
                if (Platform.isAndroid) {
                  await Permission.photos.request(); // For gallery pick
                  // storage permission might be needed for older androids, but photos usually enough for pickers
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

  void _handleCustomScan(
    BuildContext context,
    WidgetRef ref, {
    bool isInverse = false,
  }) {
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
                if (newRate != null && context.mounted) {
                  _checkPermissionsAndNavigate(context, () {
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

    showDialog(
      context: context,
      builder: (dialogCtx) => SimpleDialog(
        title: Text(l10n.chooseRate),
        children: [
          ...customRates.map(
            (r) => SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogCtx);
                _checkPermissionsAndNavigate(context, () {
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
              final newRate = await showAddEditRateDialog(context, ref);
              if (newRate != null && context.mounted) {
                _checkPermissionsAndNavigate(context, () {
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

  void _showTargetOptionsForVES(BuildContext context, WidgetRef ref) {
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
                      _checkPermissionsAndNavigate(context, () {
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
                      _checkPermissionsAndNavigate(context, () {
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
                      _handleCustomScan(context, ref, isInverse: true);
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
}
