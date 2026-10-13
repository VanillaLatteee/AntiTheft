import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var platformBridge: AntiTheftPlatformBridge?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      platformBridge = AntiTheftPlatformBridge(messenger: controller.binaryMessenger)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationDidEnterBackground(_ application: UIApplication) {
    platformBridge?.stopPlayback(status: "stopped")
    super.applicationDidEnterBackground(application)
  }

  override func applicationWillTerminate(_ application: UIApplication) {
    platformBridge?.dispose()
    super.applicationWillTerminate(application)
  }
}
