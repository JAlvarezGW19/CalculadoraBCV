import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'api_service.dart';
import 'notification_service.dart';

const String fetchRatesTask = "fetchRatesTask";
const String lastNotifiedKey = "last_notified_date_v1";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Initialize date formatting for background isolate
    await initializeDateFormatting('es', null);

    if (task == fetchRatesTask || task == "highFreqFetch") {
      try {
        final apiService = ApiService();
        final rates = await apiService.fetchRates();

        // Logic to check if we should notify
        final bool hasTomorrow = rates['has_tomorrow'] == true;

        if (hasTomorrow) {
          final String rateDate = rates['tomorrow_date'] ?? rates['rate_date'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.reload(); // Ensure we have latest data

          final bool notificationsEnabled =
              prefs.getBool('notifications_enabled') ?? true;
          if (!notificationsEnabled) {
            // Even if notifications are disabled, we might want to stop high freq polling since we have data
            return Future.value(true);
          }

          final String? lastNotified = prefs.getString(lastNotifiedKey);

          // If we haven't notified for this specific date yet
          if (lastNotified != rateDate) {
            final notificationService = NotificationService();
            await notificationService.init(); // Init in this isolate

            // Localization Logic
            String langCode = prefs.getString('selected_locale') ?? 'es';

            // Initialize formatting for the selected language
            await initializeDateFormatting(langCode, null);

            final double usd = rates['usd_tomorrow'];
            final double eur = rates['eur_tomorrow'];
            final formatter = NumberFormat("#,##0.00", "es_VE");

            final dateObj = DateTime.parse(rateDate);
            final dayName = DateFormat('EEEE', langCode).format(dateObj);
            // Capitalize first letter of day name
            final cDayName = dayName[0].toUpperCase() + dayName.substring(1);

            final dateStr = DateFormat.yMd(langCode).format(dateObj);

            // Determine if it is strictly tomorrow
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final strictTomorrow = today.add(const Duration(days: 1));
            final isStrictTomorrow =
                dateObj.year == strictTomorrow.year &&
                dateObj.month == strictTomorrow.month &&
                dateObj.day == strictTomorrow.day;

            // Simple Translation Map
            String title = "";
            String dateLabel = "Fecha";

            switch (langCode) {
              case 'en':
                title = isStrictTomorrow
                    ? "Tomorrow's BCV Rate available"
                    : "BCV Rate for $cDayName available";
                dateLabel = "Date";
                break;
              case 'pt':
                title = isStrictTomorrow
                    ? "Taxa BCV de amanhã disponível"
                    : "Taxa BCV de $cDayName disponível";
                dateLabel = "Data";
                break;
              case 'it':
                title = isStrictTomorrow
                    ? "Tasso BCV di domani disponibile"
                    : "Tasso BCV di $cDayName disponibile";
                dateLabel = "Data";
                break;
              case 'fr':
                title = isStrictTomorrow
                    ? "Taux BCV de demain disponible"
                    : "Taux BCV du $cDayName disponible";
                dateLabel = "Date";
                break;
              // Add more as needed, default to ES
              default:
                title = isStrictTomorrow
                    ? "Tasa BCV de mañana disponible"
                    : "Tasa BCV del $cDayName disponible";
                dateLabel = "Fecha";
                break;
            }

            await notificationService.showNotification(
              id: 1,
              title: title,
              body:
                  "USD = ${formatter.format(usd)} Bs. | EUR = ${formatter.format(eur)} Bs.\n$dateLabel: $dateStr",
            );

            await prefs.setString(lastNotifiedKey, rateDate);
          }
        } else {
          // If we DO NOT have tomorrow's rate yet, check if we are in CRITICAL WINDOW
          // and schedule a High Frequency Retrial (OneOff)
          final now = DateTime.now();
          // Weekdays only
          if (now.weekday >= DateTime.monday &&
              now.weekday <= DateTime.friday) {
            // Critical Window: 16:00 (4 PM) to 19:00 (7 PM)
            if (now.hour >= 16 && now.hour < 19) {
              // Schedule a One-Off task in 5 minutes
              // This creates a "loop" of checks every ~5 mins during this window
              Workmanager().registerOneOffTask(
                "highFreqFetch_id", // Constant ID to replace existing
                "highFreqFetch",
                initialDelay: const Duration(minutes: 5),
                inputData: inputData,
                existingWorkPolicy: ExistingWorkPolicy.replace,
                constraints: Constraints(networkType: NetworkType.connected),
              );
            }
          }
        }
      } catch (e) {
        // print("Error in background task: $e");
        return Future.value(false);
      }
    }
    return Future.value(true);
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  static Future<void> registerPeriodicTask() async {
    // Standard 15-minute Periodic Task
    // This serves as the heartbeat.
    await Workmanager().registerPeriodicTask(
      "periodic_bcv_check", // Changed ID to force update if needed
      fetchRatesTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update, // Update policy
    );
  }
}
