import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/language_provider.dart';
import '../../theme/app_theme.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';

class LanguageSelectionDialog extends ConsumerWidget {
  const LanguageSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(languageProvider);

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

    return AlertDialog(
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
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check, color: AppTheme.textAccent)
                  : null,
              onTap: () {
                ref
                    .read(languageProvider.notifier)
                    .setLocale(code != null ? Locale(code) : null);
                Navigator.pop(context);
              },
            );
          },
        ),
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
