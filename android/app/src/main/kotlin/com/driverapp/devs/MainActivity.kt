package com.driverapp.devs

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "webrtc_channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        println("🚀 MainActivity creada correctamente")

        createNotificationChannel()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        println("🔗 Registrando canal WebRTC en Android...")
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "ping" -> {
                    println("✅ Respuesta de ping enviada a Flutter")
                    result.success(true) // Responde a Flutter con `true`
                }
                "new_webrtc_event" -> {
                    val data = call.arguments
                    println("📡 Evento WebRTC recibido en Android: $data")
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "mqtt_service", // ID del canal (debe coincidir con notificationChannelId)
                "Servicio MQTT", // Nombre del canal
                NotificationManager.IMPORTANCE_LOW // Importancia de la notificación
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
}
