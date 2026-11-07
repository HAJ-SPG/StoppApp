package com.hajspg.stoppapp

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import org.json.JSONObject

/**
 * Native Anzeigen außerhalb der App (Spec Abschnitt 11, Variante A):
 * kleines Widget und dauerhafte Notification während einer Messung.
 * Beide lesen nur den Widget-Schnappschuss, den die App schreibt (ADR 0002).
 */
object Aussen {
    const val PREFS = "HomeWidgetPreferences"
    const val SCHNAPPSCHUSS = "schnappschuss"
    const val WARTESCHLANGE = "warteschlange"
    private const val KANAL = "messung"
    private const val BENACHRICHTIGUNG_ID = 1

    /** Der aktuelle Schnappschuss oder `null`, solange die App noch keinen geschrieben hat. */
    fun schnappschuss(context: Context): JSONObject? {
        val roh = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(SCHNAPPSCHUSS, null)
            ?: return null
        return runCatching { JSONObject(roh) }.getOrNull()
    }

    private fun JSONObject.textOderNull(name: String): String? =
        if (isNull(name)) null else optString(name)

    private fun JSONObject.posOderNull(): Int? =
        if (isNull("schritt_position")) null else optInt("schritt_position")

    /** Öffnet die App; mit [uri] an einer bestimmten Stelle (`stoppapp://kette-waehlen`, `stoppapp://einschieben`). */
    private fun appOeffnen(context: Context, uri: Uri? = null): PendingIntent =
        HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, uri)

    // ---------------------------------------------------------------- Widget

    fun widgetViews(context: Context): RemoteViews {
        val v = RemoteViews(context.packageName, R.layout.stopp_widget)
        v.setOnClickPendingIntent(R.id.widget_wurzel, appOeffnen(context))
        val s = schnappschuss(context)
        if (s == null) {
            v.setTextViewText(R.id.widget_oben, "StoppApp")
            v.setTextViewText(R.id.widget_name, "App öffnen")
            v.setViewVisibility(R.id.widget_zeit, View.GONE)
            v.setViewVisibility(R.id.widget_unten, View.GONE)
            v.setViewVisibility(R.id.widget_knopf, View.GONE)
            return v
        }

        val erledigt = s.optInt("erledigt")
        val gesamt = s.optInt("schritte_gesamt")
        val fortschritt = "$erledigt von $gesamt"
        v.setViewVisibility(R.id.widget_knopf, View.VISIBLE)
        v.setViewVisibility(R.id.widget_zeit, View.GONE)
        v.setViewVisibility(R.id.widget_unten, View.VISIBLE)

        when (s.optString("zustand")) {
            "laeuft" -> {
                val laufend = s.optJSONObject("laufend")
                v.setTextViewText(R.id.widget_oben, "Läuft")
                v.setTextViewText(R.id.widget_name, laufend?.optString("ereignis") ?: "")
                val start = laufend?.optLong("start") ?: System.currentTimeMillis()
                val basis = SystemClock.elapsedRealtime() - (System.currentTimeMillis() - start)
                v.setChronometer(R.id.widget_zeit, basis, null, true)
                v.setViewVisibility(R.id.widget_zeit, View.VISIBLE)
                v.setViewVisibility(R.id.widget_unten, View.GONE)
                knopf(context, v, "Stopp", R.drawable.widget_knopf_stopp, R.color.widget_auf_farbe)
                v.setOnClickPendingIntent(
                    R.id.widget_knopf,
                    AktionEmpfaenger.pendingIntent(context, "stopp", laufend?.posOderNull(), "widget"),
                )
            }
            "bereit" -> {
                val naechstes = s.optJSONObject("naechstes")
                v.setTextViewText(R.id.widget_oben, "Als Nächstes")
                v.setTextViewText(R.id.widget_name, naechstes?.optString("ereignis") ?: "")
                v.setTextViewText(R.id.widget_unten, fortschritt)
                knopf(context, v, "Start", R.drawable.widget_knopf_start, R.color.widget_auf_farbe)
                v.setOnClickPendingIntent(
                    R.id.widget_knopf,
                    AktionEmpfaenger.pendingIntent(context, "start", naechstes?.posOderNull(), "widget"),
                )
            }
            "erledigt" -> {
                v.setTextViewText(R.id.widget_oben, s.textOderNull("kette") ?: "Heute")
                v.setTextViewText(R.id.widget_name, "Erledigt")
                v.setTextViewText(R.id.widget_unten, fortschritt)
                knopf(context, v, "+", R.drawable.widget_knopf_leer, R.color.widget_tinte)
                v.setOnClickPendingIntent(R.id.widget_knopf, appOeffnen(context, Uri.parse("stoppapp://einschieben")))
            }
            else -> {
                v.setTextViewText(R.id.widget_oben, "Heute")
                v.setTextViewText(R.id.widget_name, "Keine Kette")
                v.setTextViewText(R.id.widget_unten, "")
                knopf(context, v, "Wählen", R.drawable.widget_knopf_leer, R.color.widget_tinte)
                v.setOnClickPendingIntent(R.id.widget_knopf, appOeffnen(context, Uri.parse("stoppapp://kette-waehlen")))
            }
        }
        return v
    }

    private fun knopf(context: Context, v: RemoteViews, text: String, hintergrund: Int, farbe: Int) {
        v.setTextViewText(R.id.widget_knopf, text)
        v.setInt(R.id.widget_knopf, "setBackgroundResource", hintergrund)
        v.setTextColor(R.id.widget_knopf, context.getColor(farbe))
    }

    // ---------------------------------------------------------------- Notification

    /** Zeigt die Notification, solange eine Messung läuft, sonst entfernt sie sie. */
    fun benachrichtigungAktualisieren(context: Context) {
        val manager = context.getSystemService(NotificationManager::class.java) ?: return
        val s = schnappschuss(context)
        val laufend = s?.optJSONObject("laufend")
        if (s == null || s.optString("zustand") != "laeuft" || laufend == null) {
            manager.cancel(BENACHRICHTIGUNG_ID)
            return
        }
        manager.createNotificationChannel(
            NotificationChannel(KANAL, "Laufende Messung", NotificationManager.IMPORTANCE_LOW).apply {
                description = "Zeigt die laufende Messung mit Stopp-Knopf."
                setShowBadge(false)
            }
        )
        val start = laufend.optLong("start")
        val seit = SimpleDateFormat("HH:mm", Locale.GERMAN).format(Date(start))
        val stopp = Notification.Action.Builder(
            Icon.createWithResource(context, R.drawable.ic_benachrichtigung_stopp),
            "STOPP",
            AktionEmpfaenger.pendingIntent(context, "stopp", laufend.posOderNull(), "notification"),
        ).build()
        val n = Notification.Builder(context, KANAL)
            .setSmallIcon(R.drawable.ic_benachrichtigung)
            .setSubText(s.textOderNull("kette") ?: "ohne Kette")
            .setContentTitle(laufend.optString("ereignis"))
            .setContentText("läuft seit $seit")
            .setWhen(start)
            .setShowWhen(true)
            .setUsesChronometer(true)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setCategory(Notification.CATEGORY_STOPWATCH)
            .setContentIntent(appOeffnen(context))
            .addAction(stopp)
            .build()
        manager.notify(BENACHRICHTIGUNG_ID, n)
    }
}
