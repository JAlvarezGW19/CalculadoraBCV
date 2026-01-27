import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';
import '../providers/iap_provider.dart';
import '../providers/bcv_provider.dart';
import '../providers/language_provider.dart';
import '../providers/notification_preferences_provider.dart';
import '../theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Extracted Widgets
import '../widgets/settings/about_app_dialog.dart';
import '../widgets/settings/language_selection_dialog.dart';
import '../widgets/settings/premium_active_card.dart';
import '../widgets/settings/premium_card.dart';
import '../widgets/settings/settings_items.dart';
import 'payment_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If translations are not ready yet (rare in run, possible in tests), fallback or wait.
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();

    final iapState = ref.watch(iapProvider);
    final iapNotifier = ref.read(iapProvider.notifier);
    final selectedLocale = ref.watch(languageProvider);
    final notificationsEnabled = ref.watch(notificationSettingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.settings,
                style: AppTheme.subtitleStyle.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Premium Card
              if (!iapState.isPremium && iapState.isAvailable)
                PremiumCard(
                  notifier: iapNotifier,
                  isLoading: iapState.isLoading,
                  products: iapState.products,
                ),

              if (iapState.isPremium) ...[
                const PremiumActiveCard(),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 32),

              // General
              Text(
                l10n.general,
                style: AppTheme.subtitleStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              SettingsListItem(
                icon: Icons.account_balance_wallet,
                title: l10n.paymentAccountsTitle,
                subtitle: l10n.paymentAccountsSubtitle,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentSettingsScreen(),
                  ),
                ),
              ),

              SettingsSwitchItem(
                icon: Icons.notifications_active_rounded,
                title: l10n.notifications,
                subtitle: l10n.notificationsSubtitle,
                value: notificationsEnabled,
                onChanged: (val) async {
                  await ref
                      .read(notificationSettingsProvider.notifier)
                      .toggle(val);
                  if (val) {
                    _checkAndNotifyImmediately(ref, l10n);
                  }
                },
              ),
              SettingsListItem(
                icon: Icons.language,
                title: l10n.language,
                subtitle: selectedLocale == null
                    ? l10n.systemDefault
                    : LanguageNotifier.getLanguageName(
                        selectedLocale.languageCode,
                      ),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => const LanguageSelectionDialog(),
                ),
              ),

              const SizedBox(height: 32),

              // Information
              Text(
                l10n.information,
                style: AppTheme.subtitleStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              SettingsListItem(
                icon: Icons.share_rounded,
                title: l10n.shareApp,
                subtitle: l10n.shareAppSubtitle,
                onTap: () async {
                  // ignore: deprecated_member_use
                  await Share.share(l10n.shareMessage);
                },
              ),
              SettingsListItem(
                icon: Icons.star_rate_rounded,
                title: l10n.rateApp,
                subtitle: l10n.rateAppSubtitle,
                onTap: () async {
                  final Uri url = Uri.parse(
                    "https://play.google.com/store/apps/details?id=com.juanalvarez.calculadorabcv",
                  );
                  if (!await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  )) {
                    debugPrint('Could not launch \$url');
                  }
                },
              ),
              SettingsListItem(
                icon: Icons.apps_rounded,
                title: l10n.moreApps,
                subtitle: l10n.moreAppsSubtitle,
                onTap: () async {
                  final Uri url = Uri.parse(
                    "https://play.google.com/store/apps/dev?id=5787072723946991693",
                  );
                  if (!await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  )) {
                    debugPrint('Could not launch \$url');
                  }
                },
              ),

              SettingsListItem(
                icon: Icons.info_outline_rounded,
                title: l10n.aboutApp,
                subtitle: l10n.aboutAppSubtitle,
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => const AboutAppDialog(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkAndNotifyImmediately(
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    try {
      final rates = await ref.read(apiServiceProvider).fetchRates();
      final bool hasTomorrow = rates['has_tomorrow'] == true;

      if (hasTomorrow) {
        final String rateDate = rates['tomorrow_date'] ?? rates['rate_date'];
        const String lastNotifiedKey = "last_notified_date_v1";
        final prefs = await SharedPreferences.getInstance();
        final String? lastNotified = prefs.getString(lastNotifiedKey);

        if (lastNotified != rateDate) {
          final notificationService = NotificationService();
          // Permissions should be handled in main/init

          final double usd = rates['usd_tomorrow'];
          final double eur = rates['eur_tomorrow'];
          final formatter = NumberFormat("#,##0.00", "es_VE");
          final dateObj = DateTime.parse(rateDate);
          final dateStr = DateFormat("dd/MM/yyyy").format(dateObj);

          await notificationService.showNotification(
            id: 1,
            title: l10n.officialRateBcv, // "Tasa Oficial del BCV" or similar
            body:
                "USD = ${formatter.format(usd)} Bs. | EUR = ${formatter.format(eur)} Bs.\n${l10n.rateDate}: $dateStr",
          );

          await prefs.setString(lastNotifiedKey, rateDate);
        }
      }
    } catch (_) {
      // Silent fail
    }
  }
}
