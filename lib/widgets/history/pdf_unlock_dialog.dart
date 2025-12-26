import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';

class PdfUnlockDialog extends StatelessWidget {
  final VoidCallback onWatchAd;

  const PdfUnlockDialog({super.key, required this.onWatchAd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: AppTheme.cardBackground,
      title: Text(
        l10n.unlockPdfTitle,
        style: const TextStyle(color: Colors.white),
      ),
      content: Text(
        l10n.unlockPdfDesc,
        style: const TextStyle(color: AppTheme.textSubtle),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.cancel,
            style: const TextStyle(color: AppTheme.textSubtle),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onWatchAd();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.textAccent,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n.watchAd.split(' ').take(2).join(' ')),
        ),
      ],
    );
  }
}
