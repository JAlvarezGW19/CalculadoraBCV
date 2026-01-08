import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/bcv_provider.dart';
import '../theme/app_theme.dart';

class CurrencyToggles extends ConsumerStatefulWidget {
  final bool hasTomorrow;
  final DateTime? tomorrowDate;

  const CurrencyToggles({
    super.key,
    required this.hasTomorrow,
    this.tomorrowDate,
  });

  @override
  ConsumerState<CurrencyToggles> createState() => _CurrencyTogglesState();
}

class _CurrencyTogglesState extends ConsumerState<CurrencyToggles> {
  bool _isNewRateSeen = false;

  @override
  void initState() {
    super.initState();
    _checkIfRateSeen();
  }

  @override
  void didUpdateWidget(CurrencyToggles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tomorrowDate != oldWidget.tomorrowDate) {
      _checkIfRateSeen();
    }
  }

  Future<void> _checkIfRateSeen() async {
    if (!widget.hasTomorrow || widget.tomorrowDate == null) return;
    final prefs = await SharedPreferences.getInstance();
    final lastSeenDate = prefs.getString(
      'last_seen_tomorrow_rate_date',
    ); // e.g. "2023-10-27"

    final currentDateStr = DateFormat(
      'yyyy-MM-dd',
    ).format(widget.tomorrowDate!);
    if (mounted) {
      setState(() {
        _isNewRateSeen = lastSeenDate == currentDateStr;
      });
    }
  }

  Future<void> _markRateAsSeen() async {
    if (widget.tomorrowDate == null) return;
    setState(() {
      _isNewRateSeen = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final currentDateStr = DateFormat(
      'yyyy-MM-dd',
    ).format(widget.tomorrowDate!);
    await prefs.setString('last_seen_tomorrow_rate_date', currentDateStr);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversionProvider);
    final l10n = AppLocalizations.of(context)!;

    String tomorrowLabel = l10n.tomorrow;
    if (widget.hasTomorrow && widget.tomorrowDate != null) {
      // Use Venezuela Time (UTC-4)
      final nowVenezuela = DateTime.now().toUtc().subtract(
        const Duration(hours: 4),
      );
      final today = DateTime(
        nowVenezuela.year,
        nowVenezuela.month,
        nowVenezuela.day,
      );
      final strictTomorrow = today.add(const Duration(days: 1));

      final isStrictTomorrow =
          widget.tomorrowDate!.year == strictTomorrow.year &&
          widget.tomorrowDate!.month == strictTomorrow.month &&
          widget.tomorrowDate!.day == strictTomorrow.day;

      if (!isStrictTomorrow) {
        final localeCode = Localizations.localeOf(context).languageCode;
        String dayName = DateFormat(
          'EEE',
          localeCode,
        ).format(widget.tomorrowDate!);
        if (dayName.endsWith('.')) {
          dayName = dayName.substring(0, dayName.length - 1);
        }
        tomorrowLabel =
            "${dayName[0].toUpperCase()}${dayName.substring(1).toLowerCase()}.";
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

        // Date Mode Toggle (Today / Tomorrow)
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
                widget.hasTomorrow
                    ? () {
                        ref
                            .read(conversionProvider.notifier)
                            .setDateMode(RateDateMode.tomorrow);
                        _markRateAsSeen();
                      }
                    : null,
                showBadge: widget.hasTomorrow && !_isNewRateSeen,
                isDisabled: !widget.hasTomorrow,
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
                offset: const Offset(0, -6),
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
