import 'package:flutter/material.dart';
import '../../providers/iap_provider.dart';
import '../../theme/app_theme.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';
import '../premium_benefits_dialog.dart';

class PremiumCard extends StatelessWidget {
  final IapNotifier notifier;
  final bool isLoading;
  final List<dynamic> products;

  const PremiumCard({
    super.key,
    required this.notifier,
    required this.isLoading,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
              onPressed: isLoading
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (_) => const PremiumBenefitsDialog(),
                      );
                    },
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
                      l10n.getPro, // Removed price display
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          // Temporarily removed oneTimePayment text
          if (l10n.oneTimePayment.isNotEmpty)
            Center(
              child: Text(
                l10n.oneTimePayment,
                style: const TextStyle(
                  color: AppTheme.textSubtle,
                  fontSize: 12,
                ),
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
}
