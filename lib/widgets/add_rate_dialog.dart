import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bcv_provider.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

Future<CustomRate?> showAddEditRateDialog(
  BuildContext context,
  WidgetRef ref, {
  CustomRate? rate,
}) {
  final nameCtrl = TextEditingController(text: rate?.name ?? "");
  final rateCtrl = TextEditingController(text: rate?.rate.toString() ?? "");

  return showDialog<CustomRate>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.cardBackground,
      title: Text(
        rate == null ? "Nueva Tasa" : "Editar Tasa",
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameCtrl,
            maxLength: 10, // Max 10 chars
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Nombre (Max 10)",
              counterStyle: TextStyle(color: AppTheme.textSubtle),
              labelStyle: TextStyle(color: AppTheme.textSubtle),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.textSubtle),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: rateCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Tasa (Bolívares)",
              labelStyle: TextStyle(color: AppTheme.textSubtle),
              enabledBorder: UnderlineInputBorder(
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
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            "Cancelar",
            style: TextStyle(color: AppTheme.textSubtle),
          ),
        ),
        TextButton(
          onPressed: () {
            final val = double.tryParse(
              rateCtrl.text.replaceAll('.', '').replaceAll(',', '.'),
            );
            final name = nameCtrl.text.trim();

            if (name.isNotEmpty && val != null) {
              // Also validate max length just in case
              if (name.length > 10) return;

              // Validate duplicate name
              final existingRates = ref.read(customRatesProvider);
              final isDuplicate = existingRates.any(
                (r) =>
                    r.name.toLowerCase() == name.toLowerCase() &&
                    (rate == null || r.id != rate.id),
              );

              if (isDuplicate) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Ya existe una tasa con ese nombre"),
                    backgroundColor: Colors.redAccent,
                    duration: Duration(seconds: 2),
                  ),
                );
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
          child: const Text(
            "Guardar",
            style: TextStyle(color: AppTheme.textAccent),
          ),
        ),
      ],
    ),
  );
}
