import 'package:flutter/material.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';
import '../services/payment_data_service.dart';
import '../models/user_account.dart';

class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
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

  void _showAddEditDialog([UserAccount? account]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AccountForm(
        account: account,
        existingAccounts: _accounts,
        onSave: (newAccount) async {
          await _service.saveAccount(newAccount);
          _loadAccounts();
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _confirmDelete(UserAccount account) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountContent(account.alias)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              await _service.deleteAccount(account.id);
              _loadAccounts();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(
              l10n.deleteAction,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentSettings), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noAccounts,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditDialog(),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addAccount),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _accounts.length,
              itemBuilder: (context, index) {
                final acc = _accounts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        acc.bankCode.substring(2), // Show last 2 digits
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      acc.alias,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${acc.bankName}\n${acc.phone}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDelete(acc),
                    ),
                    onTap: () => _showAddEditDialog(acc),
                  ),
                );
              },
            ),
      floatingActionButton: _accounts.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _showAddEditDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _AccountForm extends StatefulWidget {
  final UserAccount? account;
  final List<UserAccount> existingAccounts;
  final Function(UserAccount) onSave;

  const _AccountForm({
    this.account,
    required this.existingAccounts,
    required this.onSave,
  });

  @override
  State<_AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<_AccountForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _aliasCtrl;
  late TextEditingController _ciCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _accountNumCtrl;
  String? _selectedBankCode;

  // Default to pagoMovil unless editing an existing transfer account
  late AccountType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.account?.type ?? AccountType.pagoMovil;

    _aliasCtrl = TextEditingController(text: widget.account?.alias ?? '');
    _ciCtrl = TextEditingController(text: widget.account?.ci ?? '');
    _phoneCtrl = TextEditingController(text: widget.account?.phone ?? '');
    _accountNumCtrl = TextEditingController(
      text: widget.account?.accountNumber ?? '',
    );
    _selectedBankCode = widget.account?.bankCode;
  }

  bool _isDuplicate() {
    final l10n = AppLocalizations.of(context)!;

    for (final existing in widget.existingAccounts) {
      // Skip if we're editing the same account
      if (widget.account != null && existing.id == widget.account!.id) {
        continue;
      }

      // Check if alias already exists
      if (existing.alias.toLowerCase() == _aliasCtrl.text.toLowerCase()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.aliasAlreadyExists(_aliasCtrl.text)),
            backgroundColor: Colors.red,
          ),
        );
        return true;
      }

      // Check if all data matches (same bank, CI, phone/account)
      final sameBank = existing.bankCode == _selectedBankCode;
      final sameCi = existing.ci == _ciCtrl.text;
      final sameType = existing.type == _selectedType;

      if (sameBank && sameCi && sameType) {
        if (_selectedType == AccountType.pagoMovil) {
          if (existing.phone == _phoneCtrl.text) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.pagoMovilAlreadyExists(existing.alias)),
                backgroundColor: Colors.red,
              ),
            );
            return true;
          }
        } else {
          if (existing.accountNumber == _accountNumCtrl.text) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.bankAccountAlreadyExists(existing.alias)),
                backgroundColor: Colors.red,
              ),
            );
            return true;
          }
        }
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Sort banks by code
    final bankEntries = BankData.banks.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final isPagoMovil = _selectedType == AccountType.pagoMovil;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                widget.account == null ? l10n.newAccount : l10n.editAccount,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Type Selector
              SegmentedButton<AccountType>(
                segments: [
                  ButtonSegment(
                    value: AccountType.pagoMovil,
                    label: Text(l10n.pagoMovil),
                    icon: const Icon(Icons.smartphone),
                  ),
                  ButtonSegment(
                    value: AccountType.transferencia,
                    label: Text(l10n.bankTransfer),
                    icon: const Icon(Icons.account_balance),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<AccountType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _aliasCtrl,
                decoration: InputDecoration(
                  labelText: l10n.aliasLabel,
                  prefixIcon: const Icon(Icons.label_outline),
                ),
                validator: (v) => v!.isEmpty ? l10n.requiredField : null,
              ),
              const SizedBox(height: 12),

              // Bank Selector (Only for Pago Movil or manual selection needed)
              if (isPagoMovil)
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _selectedBankCode,
                  decoration: InputDecoration(
                    labelText: l10n.bankLabel,
                    prefixIcon: const Icon(Icons.account_balance),
                  ),
                  isExpanded: true,
                  items: bankEntries.map((e) {
                    return DropdownMenuItem(
                      value: e.key,
                      child: Text(
                        "${e.key} - ${e.value}",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedBankCode = v),
                  validator: (v) => v == null ? l10n.selectBank : null,
                ),

              // Detected Bank Display (Only for Transferencia)
              if (!isPagoMovil && _selectedBankCode != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.bankLabel,
                      prefixIcon: const Icon(Icons.account_balance),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).cardColor.withValues(alpha: 0.5),
                    ),
                    child: Text(
                      "$_selectedBankCode - ${BankData.banks[_selectedBankCode]}",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // CI Field (Common)
              TextFormField(
                controller: _ciCtrl,
                keyboardType:
                    TextInputType.text, // Alphanumeric for V-1234 or J-1234
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: '${l10n.ciLabel} (V12345678)',
                  prefixIcon: const Icon(Icons.perm_identity),
                ),
                validator: (v) => v!.isEmpty ? l10n.requiredField : null,
              ),
              const SizedBox(height: 12),

              // Phone Field (Only for Pago Movil)
              if (isPagoMovil)
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: '${l10n.phoneLabel} (0414...)',
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  validator: (v) {
                    if (isPagoMovil && (v == null || v.isEmpty)) {
                      return l10n.requiredField;
                    }
                    return null;
                  },
                ),

              // Account Number Field (Only for Transferencia)
              if (!isPagoMovil)
                TextFormField(
                  controller: _accountNumCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 20,
                  onChanged: (value) {
                    // Auto-detect bank from first 4 digits
                    if (value.length >= 4) {
                      final code = value.substring(0, 4);
                      if (BankData.banks.containsKey(code)) {
                        if (_selectedBankCode != code) {
                          setState(() {
                            _selectedBankCode = code;
                          });
                        }
                      }
                    } else if (_selectedBankCode != null &&
                        widget.account == null) {
                      // Reset if editing new account and digits < 4
                      // But keep if editing existing one unless user clears it
                      // Actually safer to just keep last detected
                    }
                    setState(() {}); // Trigger rebuild for visual feedback
                  },
                  decoration: InputDecoration(
                    labelText: l10n.accountNumberLabel,
                    prefixIcon: const Icon(Icons.numbers),
                    suffixIcon: _accountNumCtrl.text.length == 20
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : _accountNumCtrl.text.isNotEmpty
                        ? Icon(Icons.info_outline, color: Colors.orange)
                        : null,
                    helperText: _accountNumCtrl.text.isEmpty
                        ? l10n.accountDigitsHelper
                        : l10n.accountDigitsCount(
                            '${_accountNumCtrl.text.length}',
                          ),
                    helperStyle: TextStyle(
                      color: _accountNumCtrl.text.length == 20
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  validator: (v) {
                    if (!isPagoMovil) {
                      if (v == null || v.length != 20) {
                        return l10n.accountDigitsExact;
                      }
                      // Validate bank code exists
                      if (v.length >= 4) {
                        final code = v.substring(0, 4);
                        if (!BankData.banks.containsKey(code)) {
                          return 'Código de banco inválido ($code)';
                        }
                      }
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Check for duplicates
                    if (_isDuplicate()) {
                      return; // Don't save if duplicate
                    }

                    final newAccount = UserAccount(
                      id:
                          widget.account?.id ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      alias: _aliasCtrl.text,
                      bankCode: _selectedBankCode!,
                      bankName: BankData.banks[_selectedBankCode]!,
                      ci: _ciCtrl.text,
                      phone: isPagoMovil ? _phoneCtrl.text : '',
                      accountNumber: !isPagoMovil ? _accountNumCtrl.text : '',
                      type: _selectedType,
                    );
                    widget.onSave(newAccount);
                  }
                },
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
