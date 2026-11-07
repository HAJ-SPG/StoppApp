package com.hajspg.stoppapp

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import java.util.UUID
import org.json.JSONArray
import org.json.JSONObject

/**
 * Nimmt einen Tipp auf Start oder Stopp aus Widget oder Notification entgegen:
 * schreibt ihn mit dem Moment des Tippens in die Warteschlange und weckt die
 * App im Hintergrund, die ihn anwendet und einen neuen Schnappschuss schreibt.
 */
class AktionEmpfaenger : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val aktion = intent.getStringExtra(EXTRA_AKTION) ?: return
        val eintrag = JSONObject()
            .put("id", UUID.randomUUID().toString())
            .put("aktion", aktion)
            .put("zeitpunkt", System.currentTimeMillis())
            .put("quelle", intent.getStringExtra(EXTRA_QUELLE) ?: "widget")
            .put(
                "schritt_position",
                if (intent.hasExtra(EXTRA_POSITION)) intent.getIntExtra(EXTRA_POSITION, 0) else JSONObject.NULL,
            )

        val prefs = context.getSharedPreferences(Aussen.PREFS, Context.MODE_PRIVATE)
        synchronized(AktionEmpfaenger::class.java) {
            val liste = runCatching { JSONArray(prefs.getString(Aussen.WARTESCHLANGE, null) ?: "[]") }
                .getOrDefault(JSONArray())
            liste.put(eintrag)
            prefs.edit().putString(Aussen.WARTESCHLANGE, liste.toString()).commit()
        }

        try {
            HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse("stoppapp://warteschlange")).send()
        } catch (e: Exception) {
            // Rückfall: Die App arbeitet die Warteschlange beim nächsten Öffnen ab.
            Log.w("StoppApp", "Hintergrund nicht erreichbar", e)
        }
    }

    companion object {
        private const val EXTRA_AKTION = "aktion"
        private const val EXTRA_POSITION = "schritt_position"
        private const val EXTRA_QUELLE = "quelle"

        fun pendingIntent(context: Context, aktion: String, position: Int?, quelle: String): PendingIntent {
            val intent = Intent(context, AktionEmpfaenger::class.java).apply {
                action = "com.hajspg.stoppapp.$aktion.$quelle"
                putExtra(EXTRA_AKTION, aktion)
                putExtra(EXTRA_QUELLE, quelle)
                if (position != null) putExtra(EXTRA_POSITION, position)
            }
            val code = (aktion + quelle).hashCode()
            return PendingIntent.getBroadcast(
                context,
                code,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
    }
}
