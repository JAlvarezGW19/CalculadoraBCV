import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';
import '../providers/iap_provider.dart';
import '../theme/app_theme.dart';

class PremiumBenefitsDialog extends ConsumerWidget {
  const PremiumBenefitsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final iapNotifier = ref.read(iapProvider.notifier);

    return AlertDialog(
      backgroundColor: AppTheme.cardBackground,
      title: const Text(
        "Google Play Review Mode",
        style: TextStyle(color: Colors.white),
      ),
      content: Text(
        l10n.activateProBetaTitle,
        style: const TextStyle(color: AppTheme.textSubtle),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            iapNotifier.enableProBeta();
          },
          child: Text(
            l10n.activateProBetaAccept,
            style: const TextStyle(
              color: AppTheme.textAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
