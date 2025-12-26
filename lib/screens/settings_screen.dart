import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart'; // Import localizations
import '../providers/iap_provider.dart';
import '../providers/bcv_provider.dart';
import '../providers/language_provider.dart';
import '../providers/notification_preferences_provider.dart';
import '../theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';

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
                _buildPremiumCard(
                  context,
                  iapNotifier,
                  iapState.isLoading,
                  iapState.products,
                  l10n,
                ),

              if (iapState.isPremium) _buildPremiumActiveCard(l10n),

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

              _buildSettingItem(
                Icons.storage_rounded,
                l10n.storageNetwork,
                l10n.storageNetworkSubtitle,
                onTap: () => _showCacheDialog(context, ref, l10n),
              ),
              _buildSwitchItem(
                Icons.notifications_active_rounded,
                l10n.notifications,
                l10n.notificationsSubtitle,
                notificationsEnabled,
                (val) async {
                  await ref
                      .read(notificationSettingsProvider.notifier)
                      .toggle(val);
                  if (val) {
                    _checkAndNotifyImmediately(ref, l10n);
                  }
                },
              ),
              _buildSettingItem(
                Icons.language,
                l10n.language,
                selectedLocale == null
                    ? l10n.systemDefault
                    : LanguageNotifier.getLanguageName(
                        selectedLocale.languageCode,
                      ),
                onTap: () =>
                    _showLanguageDialog(context, ref, selectedLocale, l10n),
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

              _buildSettingItem(
                Icons.info_outline_rounded,
                l10n.aboutApp,
                l10n.aboutAppSubtitle,
                onTap: () => _showAboutDialog(context, l10n),
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

  Widget _buildSwitchItem(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, color: AppTheme.textSubtle),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppTheme.textSubtle, fontSize: 12),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTheme.textAccent;
            }
            return null;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTheme.textAccent.withValues(alpha: 0.3);
            }
            return null;
          }),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSubtle),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppTheme.textSubtle, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumCard(
    BuildContext context,
    IapNotifier notifier,
    bool isLoading,
    List<dynamic> products,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.textAccent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textAccent.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.textAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: AppTheme.textAccent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.becomePro,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitRow(
                      Icons.block,
                      "${l10n.benefitAds}: ${l10n.benefitAdsDesc}",
                    ),
                    _buildBenefitRow(
                      Icons.picture_as_pdf,
                      "${l10n.benefitPdf}: ${l10n.benefitPdfDesc}",
                    ),
                    _buildBenefitRow(
                      Icons.speed,
                      "${l10n.benefitSpeed}: ${l10n.benefitSpeedDesc}",
                    ),
                    _buildBenefitRow(
                      Icons.favorite,
                      "${l10n.benefitSupport}: ${l10n.benefitSupportDesc}",
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => notifier.buyPremium(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.textAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      "${l10n.getPro} ${_getPrice(products)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              l10n.oneTimePayment,
              style: const TextStyle(color: AppTheme.textSubtle, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => notifier.restorePurchases(),
              child: Text(
                l10n.restorePurchases,
                style: const TextStyle(
                  color: AppTheme.textSubtle,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPrice(List<dynamic> products) {
    if (products.isEmpty) return "\$2.49";
    return products.first.price;
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.textAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumActiveCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.2),
            AppTheme.cardBackground,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Colors.amber, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.proUser,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCacheDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.storageNetwork,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh, color: AppTheme.textAccent),
              title: Text(
                l10n.forceUpdate,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                l10n.forceUpdateSubtitle,
                style: const TextStyle(color: AppTheme.textSubtle),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                await ref
                    .read(apiServiceProvider)
                    .fetchRates(forceRefresh: true);
                ref.invalidate(ratesProvider);
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.updatingRates)));
              },
            ),
            const Divider(color: Colors.white10),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              title: Text(
                l10n.clearCache,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                l10n.clearCacheSubtitle,
                style: const TextStyle(color: AppTheme.textSubtle),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(apiServiceProvider).clearCache();
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.cacheCleared)));
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: AppTheme.textSubtle),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    Locale? currentLocale,
    AppLocalizations l10n,
  ) {
    final languages = [
      {'code': null, 'name': l10n.systemDefault},
      {'code': 'es', 'name': 'Español'},
      {'code': 'en', 'name': 'English'},
      {'code': 'pt', 'name': 'Português'},
      {'code': 'fr', 'name': 'Français'},
      {'code': 'de', 'name': 'Deutsch'},
      {'code': 'it', 'name': 'Italiano'},
      {'code': 'ru', 'name': 'Русский'},
      {'code': 'zh', 'name': '简体中文'},
      {'code': 'ja', 'name': '日本語'},
      {'code': 'ko', 'name': '한국어'},
      {'code': 'ar', 'name': 'العربية'},
      {'code': 'hi', 'name': 'हिन्दी'},
      {'code': 'tr', 'name': 'Türkçe'},
      {'code': 'id', 'name': 'Bahasa Indonesia'},
      {'code': 'vi', 'name': 'Tiếng Việt'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.language, style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: languages.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.white10),
            itemBuilder: (ctx, index) {
              final lang = languages[index];
              final code = lang['code'];
              final name = lang['name'] as String;
              final isSelected = currentLocale?.languageCode == code;

              return ListTile(
                title: Text(
                  name,
                  style: TextStyle(
                    color: isSelected ? AppTheme.textAccent : Colors.white,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppTheme.textAccent)
                    : null,
                onTap: () {
                  ref
                      .read(languageProvider.notifier)
                      .setLocale(code != null ? Locale(code) : null);
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: AppTheme.textSubtle),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.aboutApp, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.code, l10n.developer, "Juan Álvarez"),
            const Divider(color: Colors.white10, height: 16),
            _buildInfoRow(Icons.api, l10n.dataSource, l10n.officialRateBcv),
            const Divider(color: Colors.white10, height: 16),
            Text(
              "${l10n.legalNotice}:",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.legalNoticeText,
              style: TextStyle(
                color: AppTheme.textSubtle.withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  showLicensePage(
                    context: context,
                    applicationName: l10n.appTitle,
                    applicationVersion: "1.0.0",
                    applicationLegalese: "Developed by Juan Álvarez",
                  );
                },
                icon: const Icon(
                  Icons.description,
                  size: 14,
                  color: AppTheme.textAccent,
                ),
                label: Text(
                  l10n.openSourceLicenses,
                  style: const TextStyle(
                    color: AppTheme.textAccent,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                "${l10n.version} 1.0.0",
                style: const TextStyle(
                  color: AppTheme.textSubtle,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.close,
              style: const TextStyle(color: AppTheme.textAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, color: AppTheme.textSubtle),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppTheme.textSubtle, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSubtle),
      ),
    );
  }
}
