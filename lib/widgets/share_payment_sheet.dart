import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';
import '../models/user_account.dart';
import '../services/payment_data_service.dart';
import '../screens/payment_settings_screen.dart';

enum ShareAction { copy, share }

class SharePaymentSheet extends StatefulWidget {
  final String amount; // Clean amount string (e.g. "100,50")
  final String rawShareText; // The original text for "Solo Monto"
  final ShareAction action;

  const SharePaymentSheet({
    super.key,
    required this.amount,
    required this.rawShareText,
    required this.action,
  });

  @override
  State<SharePaymentSheet> createState() => _SharePaymentSheetState();
}

class _SharePaymentSheetState extends State<SharePaymentSheet> {
  final PaymentDataService _service = PaymentDataService();
  List<UserAccount> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final list = await _service.getAccounts();
    if (mounted) {
      setState(() {
        _accounts = list;
        _isLoading = false;
      });
    }
  }

  void _handleOption(String textToProcess) {
    if (widget.action == ShareAction.copy) {
      Clipboard.setData(ClipboardData(text: textToProcess));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copiado al portapapeles')));
    } else {
      // ignore: deprecated_member_use
      Share.share(textToProcess);
    }
    Navigator.pop(context);
  }

  String _formatPagoMovil(UserAccount acc) {
    return "${acc.bankCode} ${acc.ci} ${acc.phone} ${widget.amount}";
  }

  String _formatTransfer(UserAccount acc) {
    if (!mounted) return '';
    final l10n = AppLocalizations.of(context)!;
    return """${l10n.transferData}:
${l10n.bankLabel}: ${acc.bankName} (${acc.bankCode})
${l10n.nameLabel}: ${acc.alias}
${l10n.ciLabel}: ${acc.ci}
${l10n.accountLabel}: ${acc.accountNumber.isEmpty ? 'N/A' : acc.accountNumber}
${l10n.amountLabel}: ${widget.amount} Bs.""";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = widget.action == ShareAction.copy
        ? l10n.actionCopy
        : l10n.actionShare;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle Bar (Visual Indicator)
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20, top: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            '$title ${l10n.amountLabel}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Option: Only Amount/Text
          _buildOptionTile(
            icon: Icons.text_fields,
            title: l10n.onlyAmount,
            subtitle: widget.rawShareText,
            onTap: () => _handleOption(widget.rawShareText),
            color: Colors.blueAccent.withValues(alpha: 0.1),
            iconColor: Colors.blueAccent,
          ),

          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_accounts.isEmpty)
            _buildOptionTile(
              icon: Icons.add_circle_outline,
              title: l10n.configureAccounts,
              subtitle: l10n.configureAccountsDesc,
              onTap: () {
                Navigator.pop(context); // Close sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaymentSettingsScreen(),
                  ),
                );
              },
              color: Colors.orange.withValues(alpha: 0.1),
              iconColor: Colors.orange,
            )
          else ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 4),
              child: Text(
                l10n.yourAccounts,
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            // List of Accounts
            ListView.separated(
              physics:
                  const NeverScrollableScrollPhysics(), // Scroll managed by parent
              shrinkWrap: true,
              itemCount: _accounts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final acc = _accounts[i];
                final isPagoMovil = acc.type == AccountType.pagoMovil;

                return InkWell(
                  onTap: () {
                    if (isPagoMovil) {
                      _handleOption(_formatPagoMovil(acc));
                    } else {
                      _handleOption(_formatTransfer(acc));
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Bank Logo / Icon
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          child: Text(
                            acc.bankCode.substring(2),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Account Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                acc.alias,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    isPagoMovil
                                        ? Icons.smartphone
                                        : Icons.account_balance,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isPagoMovil
                                        ? l10n.pagoMovil
                                        : l10n.bankTransfer,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Action Icon
                        Icon(
                          isPagoMovil ? Icons.copy_all : Icons.share,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],

          // Add Account Button
          if (_accounts.isNotEmpty) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaymentSettingsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.settings, size: 16),
              label: Text(l10n.manageAccounts),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    required Color iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: iconColor, // Match theme
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: iconColor.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
