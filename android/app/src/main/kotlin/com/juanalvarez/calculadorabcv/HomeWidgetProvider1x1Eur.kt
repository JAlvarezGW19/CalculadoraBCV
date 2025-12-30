package com.juanalvarez.calculadorabcv

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class HomeWidgetProvider1x1Eur : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout_1x1_eur).apply {
                val isPremium = widgetData.getBoolean("is_premium", false)
                if (isPremium) {
                    val eurRate = widgetData.getString("eur_rate", "--")
                    setTextViewText(R.id.eur_rate_1x1, eurRate)
                } else {
                    setTextViewText(R.id.eur_rate_1x1, "PRO")
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
