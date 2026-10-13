import 'dart:async';

import 'package:protector/src/core/platform/platform_bridge.dart';
import 'package:protector/src/core/platform/platform_capabilities.dart';
import 'package:protector/src/core/storage/secure_store.dart';
import 'package:protector/src/features/siren/data/siren_repository.dart';
import 'package:protector/src/features/siren/domain/recovery_sound.dart';

final class InMemorySecureStore implements SecureStore {
  InMemorySecureStore([Map<String, String>? initial]) : values = {...?initial};

  final Map<String, String> values;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

final class AudioPlayRequest {
  const AudioPlayRequest({
    required this.path,
    required this.duration,
    required this.loop,
  });

  final String path;
  final Duration duration;
  final bool loop;
}

final class FakePlatformBridge implements PlatformBridge {
  FakePlatformBridge({
    PlatformCapabilities? capabilities,
    this.permissionResult = PermissionStatus.denied,
  }) : capabilities =
           capabilities ??
           const PlatformCapabilities(
             platformName: 'android',
             notificationPermission: PermissionStatus.notDetermined,
             localPlaybackSupported: true,
             backgroundRemotePlaybackSupported: false,
             nativeRecoveryStateVerifiable: false,
             limitations: ['Background playback is not guaranteed.'],
             batteryOptimizationExempt: false,
           );

  PlatformCapabilities capabilities;
  PermissionStatus permissionResult;
  int permissionRequestCount = 0;
  int recoveryGuideOpenCount = 0;
  int appSettingsOpenCount = 0;
  int stopCount = 0;
  final List<AudioPlayRequest> playRequests = [];
  final StreamController<AudioPlaybackEvent> _events =
      StreamController<AudioPlaybackEvent>.broadcast(sync: true);

  @override
  Stream<AudioPlaybackEvent> get audioEvents => _events.stream;

  @override
  Future<PlatformCapabilities> getCapabilities() async => capabilities;

  @override
  Future<void> openAppSettings() async => appSettingsOpenCount++;

  @override
  Future<void> openNativeRecoveryGuide() async => recoveryGuideOpenCount++;

  @override
  Future<void> playAudio({
    required String path,
    required Duration duration,
    required bool loop,
  }) async {
    playRequests.add(
      AudioPlayRequest(path: path, duration: duration, loop: loop),
    );
    _events.add(const AudioPlaybackEvent(AudioPlaybackStatus.playing));
  }

  @override
  Future<PermissionStatus> requestNotificationPermission() async {
    permissionRequestCount++;
    capabilities = PlatformCapabilities(
      platformName: capabilities.platformName,
      notificationPermission: permissionResult,
      localPlaybackSupported: capabilities.localPlaybackSupported,
      backgroundRemotePlaybackSupported:
          capabilities.backgroundRemotePlaybackSupported,
      nativeRecoveryStateVerifiable: capabilities.nativeRecoveryStateVerifiable,
      limitations: capabilities.limitations,
      batteryOptimizationExempt: capabilities.batteryOptimizationExempt,
    );
    return permissionResult;
  }

  @override
  Future<void> stopAudio() async {
    stopCount++;
    _events.add(const AudioPlaybackEvent(AudioPlaybackStatus.stopped));
  }

  Future<void> dispose() => _events.close();
}

final class FakeSirenRepository implements SirenRepository {
  RecoverySound? selected;
  RecoverySound? importResult;
  int importCount = 0;
  int deleteCount = 0;

  @override
  Future<void> deleteSelected() async {
    deleteCount++;
    selected = null;
  }

  @override
  Future<RecoverySound?> importSound() async {
    importCount++;
    selected = importResult;
    return selected;
  }

  @override
  Future<RecoverySound?> loadSelected() async => selected;
}

final class FakeAudioFilePicker implements AudioFilePicker {
  FakeAudioFilePicker(this.file);

  PickedAudioFile? file;

  @override
  Future<PickedAudioFile?> pickAudio() async => file;
}
