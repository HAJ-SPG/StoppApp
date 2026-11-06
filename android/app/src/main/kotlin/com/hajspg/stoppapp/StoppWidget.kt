package com.hajspg.stoppapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent

/** Kleines Homescreen-Widget (2×2) mit Start bzw. Stopp. */
class StoppWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val views = Aussen.widgetViews(context)
        for (id in ids) manager.updateAppWidget(id, views)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        // Die App ruft nach jedem neuen Schnappschuss `HomeWidget.updateWidget` auf.
        // Das kommt auch an, wenn kein Widget auf dem Homescreen liegt, und hält
        // so die Notification aktuell.
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            Aussen.benachrichtigungAktualisieren(context)
        }
    }
}
