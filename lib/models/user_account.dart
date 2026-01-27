import 'dart:convert';

enum AccountType { pagoMovil, transferencia }

class UserAccount {
  final String id;
  final String alias;
  final String bankCode;
  final String bankName;
  final String ci;
  final String phone;
  final String accountNumber;
  final AccountType type;

  UserAccount({
    required this.id,
    required this.alias,
    required this.bankCode,
    required this.bankName,
    required this.ci,
    this.phone = '',
    this.accountNumber = '',
    this.type = AccountType.pagoMovil,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alias': alias,
      'bankCode': bankCode,
      'bankName': bankName,
      'ci': ci,
      'phone': phone,
      'accountNumber': accountNumber,
      'type': type.index,
    };
  }

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      alias: map['alias'] ?? '',
      bankCode: map['bankCode'] ?? '',
      bankName: map['bankName'] ?? '',
      ci: map['ci'] ?? '',
      phone: map['phone'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      type: map['type'] != null
          ? AccountType.values[map['type']]
          : AccountType.pagoMovil,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserAccount.fromJson(String source) =>
      UserAccount.fromMap(json.decode(source));
}

class BankData {
  static const Map<String, String> banks = {
    '0102': 'BANCO DE VENEZUELA',
    '0104': 'BANCO VENEZOLANO DE CREDITO',
    '0105': 'BANCO MERCANTIL',
    '0108': 'BBVA PROVINCIAL',
    '0114': 'BANCARIBE',
    '0115': 'BANCO EXTERIOR',
    '0128': 'BANCO CARONI',
    '0134': 'BANESCO',
    '0137': 'BANCO SOFITASA',
    '0138': 'BANCO PLAZA',
    '0146': 'BANGENTE',
    '0151': 'BANCO FONDO COMUN',
    '0156': '100% BANCO',
    '0157': 'DELSUR BANCO UNIVERSAL',
    '0163': 'BANCO DEL TESORO',
    '0168': 'BANCRECER',
    '0169': 'R4 BANCO MICROFINANCIERO C.A.',
    '0171': 'BANCO ACTIVO',
    '0172': 'BANCAMIGA BANCO UNIVERSAL, C.A.',
    '0173': 'BANCO INTERNACIONAL DE DESARROLLO',
    '0174': 'BANPLUS',
    '0175': 'BANCO DIGITAL DE LOS TRABAJADORES',
    '0177': 'BANFANB',
    '0178': 'N58 BANCO DIGITAL',
    '0191': 'BANCO NACIONAL DE CREDITO',
    '0601': 'INSTITUTO MUNICIPAL DE CREDITO POPULAR',
  };
}
