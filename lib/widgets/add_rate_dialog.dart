import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bcv_provider.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';
import 'common/marquee_widget.dart';

Future<CustomRate?> showAddEditRateDialog(
  BuildContext context,
  WidgetRef ref, {
  CustomRate? rate,
}) {
  return showDialog<CustomRate>(
    context: context,
    builder: (ctx) {
      final nameCtrl = TextEditingController(text: rate?.name ?? "");
      final rateCtrl = TextEditingController(text: rate?.rate.toString() ?? "");
      String? errorMessage;
      // Use the builder context 'ctx' which is definitely valid and mounted in the dialog overlay
      // However, if the dialog is built, it should have access unless looking up higher up scopes is weird.
      // But 'context' passed in is from below. If we use 'ctx', we are safe inside the dialog subtree.
      // Actually, 'AppLocalizations' is usually at root. Both should work.
      // But to be 100% safe regarding the previous crash which might be context related:
      final l10n = AppLocalizations.of(ctx) ?? AppLocalizations.of(context)!;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.cardBackground,
            title: Text(
              rate == null ? l10n.newRate : l10n.editRate,
              style: const TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameCtrl,
                  maxLength: 10,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    if (errorMessage != null) {
                      setState(() {
                        errorMessage = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: l10n.rateNameLabel,
                    counterStyle: const TextStyle(color: AppTheme.textSubtle),
                    labelStyle: const TextStyle(color: AppTheme.textSubtle),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.textSubtle),
                    ),
                  ),
                ),
                // Error Marquee Area
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                    child: SizedBox(
                      height: 20,
                      child: MarqueeWidget(
                        animationDuration: const Duration(seconds: 4),
                        pauseDuration: const Duration(seconds: 1),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 10),
                TextField(
                  controller: rateCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: l10n.rateValueLabel,
                    labelStyle: const TextStyle(color: AppTheme.textSubtle),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.textSubtle),
                    ),
                  ),
                  inputFormatters: [CurrencyInputFormatter()],
                ),
              ],
            ),
            actions: [
              if (rate != null)
                TextButton(
                  onPressed: () {
                    ref.read(customRatesProvider.notifier).deleteRate(rate.id);
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    l10n.delete,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(color: AppTheme.textSubtle),
                ),
              ),
              TextButton(
                onPressed: () {
                  final val = double.tryParse(
                    rateCtrl.text.replaceAll('.', '').replaceAll(',', '.'),
                  );
                  final name = nameCtrl.text.trim();

                  if (name.isNotEmpty && val != null) {
                    if (name.length > 10) return;

                    final existingRates = ref.read(customRatesProvider);
                    final isDuplicate = existingRates.any(
                      (r) =>
                          r.name.toLowerCase() == name.toLowerCase() &&
                          (rate == null || r.id != rate.id),
                    );

                    if (isDuplicate) {
                      setState(() {
                        errorMessage = l10n.rateNameExists;
                      });
                      return;
                    }

                    CustomRate? resultRate;
                    if (rate == null) {
                      resultRate = ref
                          .read(customRatesProvider.notifier)
                          .addRate(name, val);
                    } else {
                      ref
                          .read(customRatesProvider.notifier)
                          .updateRate(rate.id, name, val);
                      resultRate = rate.copyWith(name: name, rate: val);
                    }
                    Navigator.pop(ctx, resultRate);
                  }
                },
                child: Text(
                  l10n.save,
                  style: const TextStyle(color: AppTheme.textAccent),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
