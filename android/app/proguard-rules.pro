# Waqti — R8 (flutter-security: build hardening). Flutter's default rules are
# merged automatically; these cover plugins that rely on reflection.

# flutter_local_notifications serialises with Gson.
-keep class com.dexterous.** { *; }
-keep class com.google.gson.** { *; }
-keepattributes Signature, *Annotation*, EnclosingMethod, InnerClasses
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Flutter deferred-components references Play Core which is not bundled.
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Keep Flutter/Dart entry points (already covered upstream; harmless).
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
