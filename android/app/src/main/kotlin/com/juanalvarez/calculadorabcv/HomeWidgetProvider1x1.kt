package com.juanalvarez.calculadorabcv

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class HomeWidgetProvider1x1 : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout_1x1).apply {
                val isPremium = widgetData.getBoolean("is_premium", false)
                if (isPremium) {
                    val usdRate = widgetData.getString("usd_rate", "--")
                    setTextViewText(R.id.usd_rate_1x1, usdRate)
                } else {
                    setTextViewText(R.id.usd_rate_1x1, "PRO")
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
