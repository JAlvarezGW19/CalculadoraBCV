import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsNotifier extends Notifier<bool> {
  static const _key = 'notifications_enabled';

  @override
  bool build() {
    _loadState();
    return true; // Default to enabled
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true if not set
    state = prefs.getBool(_key) ?? true;
  }

  Future<void> toggle(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
    // Note: The actual scheduling/cancellation logic might happen in main
    // or wherever the background task is configured, reading this preference.
  }
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, bool>(
      NotificationSettingsNotifier.new,
    );
