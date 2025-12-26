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
    final isLoading = iapState.isLoading;
    final products = iapState.products;

    // Listen for state changes to detect successful purchase
    ref.listen(iapProvider, (previous, next) {
      if ((previous == null || !previous.isPremium) && next.isPremium) {
        // Purchase successful!
        Navigator.of(context).pop(); // Close the benefits dialog
        _showSuccessDialog(context, l10n);
      }
    });

    return Dialog(
      backgroundColor: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.textAccent.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.textAccent.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  onPressed: isLoading ? null : () => iapNotifier.buyPremium(),
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
                  style: const TextStyle(
                    color: AppTheme.textSubtle,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => iapNotifier.restorePurchases(),
                  child: Text(
                    l10n.restorePurchases,
                    style: const TextStyle(
                      color: AppTheme.textSubtle,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel, // Or 'Close'
                    style: const TextStyle(color: AppTheme.textSubtle),
                  ),
                ),
              ),
            ],
          ),
        ),
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

  void _showSuccessDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        // Auto-close after 2.5 seconds
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (ctx.mounted && Navigator.canPop(ctx)) {
            Navigator.pop(ctx);
          }
        });

        return Dialog(
          backgroundColor: AppTheme.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.textAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.textAccent,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.proUser,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "¡Gracias por tu apoyo!", // Hardcoded friendly message or add to l10n if strict
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSubtle, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
