import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppDialog extends StatelessWidget {
  const AboutAppDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(l10n.aboutApp, style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.code, l10n.developer, "Juan Álvarez"),
          const Divider(color: Colors.white10, height: 16),
          _buildInfoRow(
            Icons.api,
            l10n.dataSource,
            l10n.officialRateBcv,
            isLink: true,
            onTap: () async {
              final Uri url = Uri.parse("http://www.bcv.org.ve/");
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                debugPrint('Could not launch \$url');
              }
            },
          ),
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
              style: const TextStyle(color: AppTheme.textSubtle, fontSize: 10),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.close,
            style: const TextStyle(color: AppTheme.textAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.textSubtle),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSubtle,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: isLink ? AppTheme.textAccent : Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: isLink
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationColor: AppTheme.textAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
