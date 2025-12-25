# =========================
# Flutter Wrapper
# =========================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# =========================
# ML Kit & Vision (Critical)
# =========================
-dontwarn com.google.mlkit.vision.text.chinese.**
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-dontwarn com.google.mlkit.vision.text.devanagari.**
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-dontwarn com.google.mlkit.vision.text.japanese.**
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-dontwarn com.google.mlkit.vision.text.korean.**
-keep class com.google.mlkit.vision.text.korean.** { *; }

-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.** { *; }
-keep class com.google.mlkit.common.** { *; }

-dontwarn com.google.android.gms.**
-keep class com.google.android.gms.internal.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# =========================
# WorkManager
# =========================
-keep class androidx.work.** { *; }
-keep class dev.fluttercommunity.workmanager.** { *; }
-keep class be.tramckrijte.workmanager.** { *; }
-dontwarn androidx.work.**

# =========================
# Local Notifications
# =========================
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# =========================
# Permission Handler
# =========================
-keep class com.baseflow.permissionhandler.** { *; }

# =========================
# Play Core & Common
# =========================
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# =========================
# General Safety
# =========================
-dontwarn javax.annotation.**
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
