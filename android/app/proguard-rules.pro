# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# WorkManager & Room Database rules (Required by better_player_plus / exoplayer / workmanager)
-keep class androidx.work.impl.WorkDatabase { *; }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class * extends androidx.room.RoomDatabase {
    <init>();
}
-keep class * extends androidx.work.ListenableWorker {
    <init>(android.content.Context, androidx.work.WorkerParameters);
}

# Better Player & ExoPlayer rules
-keep class com.jhomlala.better_player.** { *; }
-keep class androidx.media3.** { *; }
-keep class com.google.android.exoplayer2.** { *; }

# Suppress Play Store deferred components warnings
-dontwarn com.google.android.play.core.**
-dontwarn androidx.media3.**
