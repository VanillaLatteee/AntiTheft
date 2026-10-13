import AVFAudio
import Flutter
import UIKit
import UserNotifications

final class AntiTheftPlatformBridge: NSObject, FlutterStreamHandler, AVAudioPlayerDelegate {
  private static let methodChannelName = "com.antitheft.protector/platform"
  private static let eventChannelName = "com.antitheft.protector/audio_events"

  private let methodChannel: FlutterMethodChannel
  private let eventChannel: FlutterEventChannel
  private var eventSink: FlutterEventSink?
  private var audioPlayer: AVAudioPlayer?
  private var completionTimer: Timer?

  init(messenger: FlutterBinaryMessenger) {
    methodChannel = FlutterMethodChannel(
      name: Self.methodChannelName,
      binaryMessenger: messenger
    )
    eventChannel = FlutterEventChannel(
      name: Self.eventChannelName,
      binaryMessenger: messenger
    )
    super.init()
    methodChannel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call: call, result: result)
    }
    eventChannel.setStreamHandler(self)
  }

  private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getCapabilities":
      getCapabilities(result: result)
    case "requestNotificationPermission":
      requestNotificationPermission(result: result)
    case "openNativeRecoveryGuide":
      open(urlString: "https://support.apple.com/find-my", result: result)
    case "openAppSettings":
      open(urlString: UIApplication.openSettingsURLString, result: result)
    case "playAudio":
      playAudio(arguments: call.arguments, result: result)
    case "stopAudio":
      stopPlayback(status: "stopped")
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getCapabilities(result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      DispatchQueue.main.async {
        result([
          "platform": "ios",
          "notificationPermission": self.notificationStatus(settings.authorizationStatus),
          "localPlaybackSupported": true,
          "backgroundRemotePlaybackSupported": false,
          "nativeRecoveryStateVerifiable": false,
          "batteryOptimizationExempt": NSNull(),
          "limitations": [
            "Local 60-second playback is supported only while the app remains active.",
            "Volume, audio focus, interruptions, Focus modes, and device policy still apply.",
            "Apple Find My status cannot be inspected through a public iOS API.",
            "Remote notification sounds are limited and cannot guarantee a 60-second siren.",
          ],
        ])
      }
    }
  }

  private func requestNotificationPermission(result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
      _, error in
      if let error {
        DispatchQueue.main.async {
          result(
            FlutterError(
              code: "notification_permission_failed",
              message: error.localizedDescription,
              details: nil
            )
          )
        }
        return
      }
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        DispatchQueue.main.async {
          result(self.notificationStatus(settings.authorizationStatus))
        }
      }
    }
  }

  private func notificationStatus(_ status: UNAuthorizationStatus) -> String {
    switch status.rawValue {
    case 0: return "notDetermined"
    case 1: return "denied"
    case 2, 3, 4: return "granted"
    default: return "unknown"
    }
  }

  private func open(urlString: String, result: @escaping FlutterResult) {
    guard let url = URL(string: urlString) else {
      result(
        FlutterError(code: "invalid_url", message: "The system URL is invalid.", details: nil)
      )
      return
    }
    UIApplication.shared.open(url, options: [:]) { opened in
      DispatchQueue.main.async {
        if opened {
          result(nil)
        } else {
          result(
            FlutterError(
              code: "url_unavailable",
              message: "The requested system page could not be opened.",
              details: nil
            )
          )
        }
      }
    }
  }

  private func playAudio(arguments: Any?, result: @escaping FlutterResult) {
    guard
      let arguments = arguments as? [String: Any],
      let path = arguments["path"] as? String,
      let durationNumber = arguments["durationMs"] as? NSNumber
    else {
      result(
        FlutterError(
          code: "invalid_arguments",
          message: "A private audio path and duration are required.",
          details: nil
        )
      )
      return
    }

    let fileURL = URL(fileURLWithPath: path).standardizedFileURL
    let homeURL = URL(fileURLWithPath: NSHomeDirectory()).standardizedFileURL
    let supportedExtension = ["mp3", "wav"].contains(fileURL.pathExtension.lowercased())
    guard
      fileURL.path.hasPrefix(homeURL.path + "/"),
      FileManager.default.fileExists(atPath: fileURL.path),
      supportedExtension
    else {
      result(
        FlutterError(
          code: "invalid_audio",
          message: "Audio must be an app-private MP3 or WAV file.",
          details: nil
        )
      )
      return
    }

    let duration = min(max(durationNumber.doubleValue / 1000, 1), 60)
    let shouldLoop = arguments["loop"] as? Bool ?? false

    do {
      stopPlayback(status: nil)
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playback, mode: .default, options: [])
      try session.setActive(true)

      let player = try AVAudioPlayer(contentsOf: fileURL)
      player.delegate = self
      player.numberOfLoops = shouldLoop ? -1 : 0
      player.prepareToPlay()
      guard player.play() else {
        throw NSError(
          domain: "AntiTheftAudio",
          code: 1,
          userInfo: [NSLocalizedDescriptionKey: "The audio session did not start playback."]
        )
      }
      audioPlayer = player
      completionTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) {
        [weak self] _ in
        self?.stopPlayback(status: "completed")
      }
      emit(status: "playing")
      result(nil)
    } catch {
      stopPlayback(status: nil)
      result(
        FlutterError(
          code: "playback_failed",
          message: error.localizedDescription,
          details: nil
        )
      )
    }
  }

  func stopPlayback(status: String?) {
    completionTimer?.invalidate()
    completionTimer = nil
    guard let player = audioPlayer else { return }
    player.stop()
    player.delegate = nil
    audioPlayer = nil
    try? AVAudioSession.sharedInstance().setActive(
      false,
      options: .notifyOthersOnDeactivation
    )
    if let status { emit(status: status) }
  }

  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    stopPlayback(status: flag ? "completed" : "failed")
  }

  func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
    stopPlayback(status: nil)
    emit(status: "failed", message: error?.localizedDescription ?? "Audio decoding failed.")
  }

  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  private func emit(status: String, message: String? = nil) {
    var event: [String: Any] = ["status": status]
    if let message { event["message"] = message }
    eventSink?(event)
  }

  func dispose() {
    stopPlayback(status: nil)
    methodChannel.setMethodCallHandler(nil)
    eventChannel.setStreamHandler(nil)
  }
}
