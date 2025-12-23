import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'notification_service.dart';

const String fetchRatesTask = "fetchRatesTask";
const String lastNotifiedKey = "last_notified_date_v1";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == fetchRatesTask) {
      try {
        final apiService = ApiService();
        final rates = await apiService.fetchRates();

        // Logic to check if we should notify
        final bool hasTomorrow = rates['has_tomorrow'] == true;

        if (hasTomorrow) {
          final String rateDate = rates['rate_date'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.reload(); // Ensure we have latest data
          final String? lastNotified = prefs.getString(lastNotifiedKey);

          // If we haven't notified for this specific date yet
          if (lastNotified != rateDate) {
            final notificationService = NotificationService();
            await notificationService.init(); // Init in this isolate

            final double usd = rates['usd_tomorrow'];
            final double eur = rates['eur_tomorrow'];
            final formatter = NumberFormat("#,##0.00", "es_VE");

            final dateObj = DateTime.parse(rateDate);
            final dateStr = DateFormat("dd/MM").format(dateObj);

            await notificationService.showNotification(
              id: 1,
              title: "Tasa BCV Mañana Disponible",
              body:
                  "\$1 = ${formatter.format(usd)} Bs, €1 = ${formatter.format(eur)} Bs ($dateStr)",
            );

            await prefs.setString(lastNotifiedKey, rateDate);
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
    await Workmanager().registerPeriodicTask(
      "1",
      fetchRatesTask,
      frequency: const Duration(minutes: 15), // Minimum is 15 mins on Android
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}
