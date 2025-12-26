import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';
import '../providers/bcv_provider.dart';
import '../theme/app_theme.dart';

class CurrencyToggles extends ConsumerWidget {
  final bool hasTomorrow;
  final DateTime? tomorrowDate;

  const CurrencyToggles({
    super.key,
    required this.hasTomorrow,
    this.tomorrowDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversionProvider);
    final l10n = AppLocalizations.of(context)!;

    String tomorrowLabel = l10n.tomorrow; // Use localized string
    if (hasTomorrow && tomorrowDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final strictTomorrow = today.add(const Duration(days: 1));

      final isStrictTomorrow =
          tomorrowDate!.year == strictTomorrow.year &&
          tomorrowDate!.month == strictTomorrow.month &&
          tomorrowDate!.day == strictTomorrow.day;

      if (!isStrictTomorrow) {
        // If "tomorrow" data is actually Monday when today is Friday, show "Monday"
        // But we need to make sure this is localized properly.
        // DateFormat('EEEE', 'es') was hardcoded.
        // We should use the current locale for DateFormat.
        final localeCode = Localizations.localeOf(context).languageCode;
        final dayName = DateFormat('EEEE', localeCode).format(tomorrowDate!);
        tomorrowLabel =
            dayName[0].toUpperCase() + dayName.substring(1).toLowerCase();
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Currency Toggle
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildToggleButton(
                "USD",
                state.currency == CurrencyType.usd,
                () => ref
                    .read(conversionProvider.notifier)
                    .setCurrency(CurrencyType.usd),
              ),
              _buildToggleButton(
                "EUR",
                state.currency == CurrencyType.eur,
                () => ref
                    .read(conversionProvider.notifier)
                    .setCurrency(CurrencyType.eur),
              ),
              _buildToggleButton(
                l10n.ratePers, // Was "Pers."
                state.currency == CurrencyType.custom,
                () => ref
                    .read(conversionProvider.notifier)
                    .setCurrency(CurrencyType.custom),
              ),
            ],
          ),
        ),

        // Date Mode Toggle (Hoy / Mañana) - Only if NOT custom
        if (state.currency != CurrencyType.custom)
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildToggleButton(
                  l10n.today,
                  state.dateMode == RateDateMode.today,
                  () => ref
                      .read(conversionProvider.notifier)
                      .setDateMode(RateDateMode.today),
                ),
                _buildToggleButton(
                  tomorrowLabel,
                  state.dateMode == RateDateMode.tomorrow,
                  hasTomorrow
                      ? () => ref
                            .read(conversionProvider.notifier)
                            .setDateMode(RateDateMode.tomorrow)
                      : null,
                  showBadge: hasTomorrow,
                  isDisabled: !hasTomorrow,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildToggleButton(
    String text,
    bool isSelected,
    VoidCallback? onTap, {
    bool showBadge = false,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                color: isDisabled
                    ? AppTheme.textSubtle.withValues(alpha: 0.3)
                    : (isSelected ? Colors.white : AppTheme.textSubtle),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            if (showBadge) ...[
              const SizedBox(width: 6),
              Transform.translate(
                offset: const Offset(0, -3),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
