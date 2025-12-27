import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

class HomeWidgetService {
  static const String groupId =
      'group.com.juanalvarez.calculadorabcv'; // Only needed for iOS, but good practice
  static const String androidWidgetProvider = 'HomeWidgetProvider';

  static Future<void> updateWidgetData({
    required double usdRate,
    required double eurRate,
    required String rateDate,
    bool isPremium = false,
  }) async {
    final formatter = NumberFormat("##0.00", "es_VE");

    // Format date nicely (e.g. 26/12)
    String formattedDate = "--/--";
    try {
      final dateObj = DateTime.parse(rateDate);
      formattedDate = DateFormat("dd/MM").format(dateObj);
    } catch (_) {
      formattedDate = rateDate;
    }

    // Save Data to Shared Preferences used by Native Widget
    await HomeWidget.saveWidgetData<String>(
      'usd_rate',
      formatter.format(usdRate),
    );
    await HomeWidget.saveWidgetData<String>(
      'eur_rate',
      formatter.format(eurRate),
    );
    await HomeWidget.saveWidgetData<String>('rate_date', formattedDate);
    // Explicitly save as Boolean for Kotlin to read easily, or String "true"/"false"
    await HomeWidget.saveWidgetData<bool>('is_premium', isPremium);

    // Trigger Update for Standard Widget
    await HomeWidget.updateWidget(
      name: androidWidgetProvider,
      androidName: androidWidgetProvider,
    );

    // Trigger Update for 1x1 Widget
    await HomeWidget.updateWidget(
      name: 'HomeWidgetProvider1x1',
      androidName: 'HomeWidgetProvider1x1',
    );
  }
}
