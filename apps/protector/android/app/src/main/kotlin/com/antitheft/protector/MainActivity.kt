package com.antitheft.protector

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private var platformBridge: AntiTheftPlatformBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        platformBridge = AntiTheftPlatformBridge(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        if (platformBridge?.onRequestPermissionsResult(requestCode) == true) {
            return
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    override fun onStop() {
        platformBridge?.stopPlayback("stopped")
        super.onStop()
    }

    override fun onDestroy() {
        platformBridge?.dispose()
        platformBridge = null
        super.onDestroy()
    }
}
