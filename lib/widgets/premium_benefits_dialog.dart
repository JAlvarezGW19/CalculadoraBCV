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
    final iapState = ref.watch(iapProvider);
    final iapNotifier = ref.read(iapProvider.notifier);

    // Find the product
    final product = iapState.products.isNotEmpty
        ? iapState.products.first
        : null;
    final price = product?.price ?? '';

    return AlertDialog(
      backgroundColor: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: const BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.star, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    l10n.becomePro,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildBenefitRow(
                    context,
                    Icons.block_flipped,
                    l10n.benefitAds,
                    l10n.benefitAdsDesc,
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitRow(
                    context,
                    Icons.picture_as_pdf,
                    l10n.benefitPdf,
                    l10n.benefitPdfDesc,
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitRow(
                    context,
                    Icons.bolt,
                    l10n.benefitSpeed,
                    l10n.benefitSpeedDesc,
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitRow(
                    context,
                    Icons.favorite,
                    l10n.benefitSupport,
                    l10n.benefitSupportDesc,
                  ),
                ],
              ),
            ),

            if (iapState.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  iapState.error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: iapState.isLoading
                    ? null
                    : () => iapNotifier.buyPremium(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textAccent,
                  foregroundColor: AppTheme.background,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: iapState.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.background,
                        ),
                      )
                    : Text(
                        product != null ? "${l10n.getPro} $price" : l10n.getPro,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),

            TextButton(
              onPressed: iapState.isLoading
                  ? null
                  : () => iapNotifier.restorePurchases(),
              child: Text(
                l10n.restorePurchases,
                style: TextStyle(
                  color: AppTheme.textSubtle.withValues(alpha: 0.7),
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.textAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.textAccent, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSubtle,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
