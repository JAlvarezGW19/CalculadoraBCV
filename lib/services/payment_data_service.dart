import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_account.dart';

class PaymentDataService {
  static const String _key = 'user_accounts_v1';

  Future<List<UserAccount>> getAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? list = prefs.getStringList(_key);
    if (list == null) return [];
    return list.map((item) => UserAccount.fromJson(item)).toList();
  }

  Future<void> saveAccount(UserAccount account) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = await getAccounts();

    // Check if editing (exists by ID)
    final index = accounts.indexWhere((element) => element.id == account.id);
    if (index >= 0) {
      accounts[index] = account;
    } else {
      accounts.add(account);
    }

    final List<String> encoded = accounts.map((e) => e.toJson()).toList();
    await prefs.setStringList(_key, encoded);
  }

  Future<void> deleteAccount(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = await getAccounts();
    accounts.removeWhere((element) => element.id == id);
    final List<String> encoded = accounts.map((e) => e.toJson()).toList();
    await prefs.setStringList(_key, encoded);
  }
}
