import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/bcv_provider.dart';
import '../../theme/app_theme.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';

class CacheManagementDialog extends ConsumerWidget {
  const CacheManagementDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
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
              Navigator.pop(context);
              await ref.read(apiServiceProvider).fetchRates(forceRefresh: true);
              ref.invalidate(ratesProvider);
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.updatingRates)));
            },
          ),
          const Divider(color: Colors.white10),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: Text(
              l10n.clearCache,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              l10n.clearCacheSubtitle,
              style: const TextStyle(color: AppTheme.textSubtle),
            ),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(apiServiceProvider).clearCache();
              ref.invalidate(ratesProvider); // Force UI update
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
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.cancel,
            style: const TextStyle(color: AppTheme.textSubtle),
          ),
        ),
      ],
    );
  }
}
