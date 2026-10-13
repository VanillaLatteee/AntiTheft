package com.antitheft.protector

import android.Manifest
import android.app.NotificationManager
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class AntiTheftPlatformBridge(
    private val activity: MainActivity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler, Player.Listener {
    companion object {
        private const val methodChannelName = "com.antitheft.protector/platform"
        private const val eventChannelName = "com.antitheft.protector/audio_events"
        private const val notificationRequestCode = 7101
    }

    private val methodChannel = MethodChannel(messenger, methodChannelName)
    private val eventChannel = EventChannel(messenger, eventChannelName)
    private val handler = Handler(Looper.getMainLooper())
    private val player = ExoPlayer.Builder(activity).build().also {
        it.addListener(this)
        it.setAudioAttributes(
            AudioAttributes.Builder()
                .setContentType(C.AUDIO_CONTENT_TYPE_MUSIC)
                .setUsage(C.USAGE_MEDIA)
                .build(),
            true,
        )
    }
    private var eventSink: EventChannel.EventSink? = null
    private var pendingPermissionResult: MethodChannel.Result? = null
    private var completionRunnable: Runnable? = null

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getCapabilities" -> result.success(capabilities())
            "requestNotificationPermission" -> requestNotificationPermission(result)
            "openNativeRecoveryGuide" -> openUrl(
                "https://www.google.com/android/find/about",
                result,
            )
            "openAppSettings" -> openAppSettings(result)
            "playAudio" -> playAudio(call.arguments, result)
            "stopAudio" -> {
                stopPlayback("stopped")
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun capabilities(): Map<String, Any?> {
        val powerManager = activity.getSystemService(Context.POWER_SERVICE) as PowerManager
        val batteryExempt = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            powerManager.isIgnoringBatteryOptimizations(activity.packageName)
        } else {
            true
        }
        return mapOf(
            "platform" to "android",
            "notificationPermission" to notificationPermissionStatus(),
            "localPlaybackSupported" to true,
            "backgroundRemotePlaybackSupported" to false,
            "nativeRecoveryStateVerifiable" to false,
            "batteryOptimizationExempt" to batteryExempt,
            "limitations" to listOf(
                "Local 60-second playback is supported only while the app remains active.",
                "Media volume, audio focus, Do Not Disturb, and device policy still apply.",
                "Google Find Hub status cannot be inspected through a public Android API.",
            ),
        )
    }

    private fun notificationPermissionStatus(): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            activity.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            return "denied"
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val manager = activity.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (!manager.areNotificationsEnabled()) return "denied"
        }
        return "granted"
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            activity.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            result.success(notificationPermissionStatus())
            return
        }
        if (pendingPermissionResult != null) {
            result.error("permission_in_progress", "A permission request is already active.", null)
            return
        }
        pendingPermissionResult = result
        activity.requestPermissions(
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            notificationRequestCode,
        )
    }

    fun onRequestPermissionsResult(requestCode: Int): Boolean {
        if (requestCode != notificationRequestCode) return false
        pendingPermissionResult?.success(notificationPermissionStatus())
        pendingPermissionResult = null
        return true
    }

    private fun openUrl(url: String, result: MethodChannel.Result) {
        try {
            activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
            result.success(null)
        } catch (error: ActivityNotFoundException) {
            result.error("activity_not_found", "No browser can open the recovery guide.", null)
        }
    }

    private fun openAppSettings(result: MethodChannel.Result) {
        try {
            val intent = Intent(
                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                Uri.fromParts("package", activity.packageName, null),
            )
            activity.startActivity(intent)
            result.success(null)
        } catch (error: ActivityNotFoundException) {
            result.error("activity_not_found", "App settings are unavailable.", null)
        }
    }

    private fun playAudio(arguments: Any?, result: MethodChannel.Result) {
        val args = arguments as? Map<*, *>
        val path = args?.get("path") as? String
        val durationMs = (args?.get("durationMs") as? Number)?.toLong()?.coerceIn(1_000, 60_000)
        val loop = args?.get("loop") as? Boolean ?: false
        if (path == null || durationMs == null) {
            result.error("invalid_arguments", "A private audio path and duration are required.", null)
            return
        }

        try {
            val file = File(path).canonicalFile
            val appRoot = File(activity.applicationInfo.dataDir).canonicalFile
            val isPrivate = file.path.startsWith(appRoot.path + File.separator)
            val supportedExtension = file.extension.lowercase() in setOf("mp3", "wav")
            if (!isPrivate || !file.isFile || !supportedExtension) {
                result.error("invalid_audio", "Audio must be an app-private MP3 or WAV file.", null)
                return
            }

            stopPlayback(null)
            player.repeatMode = if (loop) Player.REPEAT_MODE_ONE else Player.REPEAT_MODE_OFF
            player.setMediaItem(MediaItem.fromUri(Uri.fromFile(file)))
            player.prepare()
            player.play()
            completionRunnable = Runnable { stopPlayback("completed") }.also {
                handler.postDelayed(it, durationMs)
            }
            emit("playing")
            result.success(null)
        } catch (error: Exception) {
            result.error("playback_failed", error.message ?: "Audio playback failed.", null)
        }
    }

    fun stopPlayback(status: String?) {
        completionRunnable?.let(handler::removeCallbacks)
        completionRunnable = null
        if (player.playbackState != Player.STATE_IDLE || player.mediaItemCount > 0) {
            player.stop()
            player.clearMediaItems()
            if (status != null) emit(status)
        }
    }

    override fun onPlaybackStateChanged(playbackState: Int) {
        if (playbackState == Player.STATE_ENDED) stopPlayback("completed")
    }

    override fun onPlayerError(error: PlaybackException) {
        stopPlayback(null)
        emit("failed", error.message)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun emit(status: String, message: String? = null) {
        eventSink?.success(mapOf("status" to status, "message" to message))
    }

    fun dispose() {
        stopPlayback(null)
        pendingPermissionResult?.error(
            "activity_destroyed",
            "The activity closed before permission was resolved.",
            null,
        )
        pendingPermissionResult = null
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        player.removeListener(this)
        player.release()
    }
}
