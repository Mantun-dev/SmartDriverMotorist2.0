# === JITSI MEET SDK ===
-keep class org.jitsi.** { *; }
-keep interface org.jitsi.** { *; }

-keep class com.facebook.react.** { *; }
-dontwarn com.facebook.react.**

-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**

# === OKHTTP (si se usa) ===
-dontwarn okhttp3.**
-keep class okhttp3.** { *; }

# === GIPHY SDK ===
-keep class com.giphy.sdk.** { *; }
-dontwarn com.giphy.sdk.**

# === FRESCO / FACEBOOK IMAGE PIPELINE ===
-keep class com.facebook.imagepipeline.** { *; }
-keep class com.facebook.** { *; }
-dontwarn com.facebook.**

# === KOTLINX Parcelize ===
-keep class kotlinx.parcelize.** { *; }
-keep class kotlinx.serialization.** { *; }

# === FLUTTER / ANNOTATIONS / REFLECTION ===
-keepattributes *Annotation*
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Preserva miembros anotados por Kotlin
-keepclassmembers class * {
    @kotlin.Metadata *;
}

# (Opcional) Si tienes errores con R8 y clases faltantes en release
-keep class com.yourpackage.** { *; }  # <-- Puedes especificar tu paquete aquí si lo deseas

