package com.juanalvarez.calculadorabcv

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class HomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Open App on Click
                // val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                //     context,
                //     MainActivity::class.java
                // )
                // setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                // Get Data from Shared Prefs (saved by Flutter)
                val isPremium = widgetData.getBoolean("is_premium", false)
                
                if (isPremium) {
                    val usdRate = widgetData.getString("usd_rate", "--")
                    val eurRate = widgetData.getString("eur_rate", "--")
                    val date = widgetData.getString("rate_date", "--/--")

                    setTextViewText(R.id.usd_rate, usdRate)
                    setTextViewText(R.id.eur_rate, eurRate)
                    setTextViewText(R.id.last_updated, "Fecha: $date")
                    
                    // Ensure normal visibility
                    setViewVisibility(R.id.usd_rate, android.view.View.VISIBLE)
                    setViewVisibility(R.id.eur_rate, android.view.View.VISIBLE)
                } else {
                    // Locked State
                    setTextViewText(R.id.widget_title, "Requiere PRO")
                    setTextViewText(R.id.usd_rate, "🔒")
                    setTextViewText(R.id.eur_rate, "🔒")
                    setTextViewText(R.id.last_updated, "Desbloquear en App")
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
