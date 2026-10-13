import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:protector/src/core/platform/platform_capabilities.dart';

enum AudioPlaybackStatus { playing, stopped, completed, failed }

final class AudioPlaybackEvent {
  const AudioPlaybackEvent(this.status, {this.message});

  factory AudioPlaybackEvent.fromMap(Map<Object?, Object?> map) {
    final status = switch (map['status']) {
      'playing' => AudioPlaybackStatus.playing,
      'completed' => AudioPlaybackStatus.completed,
      'failed' => AudioPlaybackStatus.failed,
      _ => AudioPlaybackStatus.stopped,
    };
    return AudioPlaybackEvent(status, message: map['message'] as String?);
  }

  final AudioPlaybackStatus status;
  final String? message;
}

abstract interface class PlatformBridge {
  Future<PlatformCapabilities> getCapabilities();

  Future<PermissionStatus> requestNotificationPermission();

  Future<void> openNativeRecoveryGuide();

  Future<void> openAppSettings();

  Future<void> playAudio({
    required String path,
    required Duration duration,
    required bool loop,
  });

  Future<void> stopAudio();

  Stream<AudioPlaybackEvent> get audioEvents;
}

final class MethodChannelPlatformBridge implements PlatformBridge {
  MethodChannelPlatformBridge({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  }) : _methodChannel =
           methodChannel ??
           const MethodChannel('com.antitheft.protector/platform'),
       _eventChannel =
           eventChannel ??
           const EventChannel('com.antitheft.protector/audio_events');

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  Stream<AudioPlaybackEvent>? _events;

  @override
  Stream<AudioPlaybackEvent> get audioEvents =>
      _events ??= _eventChannel
          .receiveBroadcastStream()
          .where((event) => event is Map)
          .map(
            (event) => AudioPlaybackEvent.fromMap(
              Map<Object?, Object?>.from(event as Map),
            ),
          );

  @override
  Future<PlatformCapabilities> getCapabilities() async {
    try {
      final value = await _methodChannel.invokeMethod<Map<Object?, Object?>>(
        'getCapabilities',
      );
      return PlatformCapabilities.fromMap(value ?? const {});
    } on MissingPluginException {
      return PlatformCapabilities.unavailable(_fallbackPlatformName);
    } on PlatformException {
      return PlatformCapabilities.unavailable(_fallbackPlatformName);
    }
  }

  @override
  Future<PermissionStatus> requestNotificationPermission() async {
    final value = await _methodChannel.invokeMethod<String>(
      'requestNotificationPermission',
    );
    return PermissionStatus.fromWireValue(value);
  }

  @override
  Future<void> openNativeRecoveryGuide() =>
      _methodChannel.invokeMethod<void>('openNativeRecoveryGuide');

  @override
  Future<void> openAppSettings() =>
      _methodChannel.invokeMethod<void>('openAppSettings');

  @override
  Future<void> playAudio({
    required String path,
    required Duration duration,
    required bool loop,
  }) {
    return _methodChannel.invokeMethod<void>('playAudio', {
      'path': path,
      'durationMs': duration.inMilliseconds,
      'loop': loop,
    });
  }

  @override
  Future<void> stopAudio() => _methodChannel.invokeMethod<void>('stopAudio');

  String get _fallbackPlatformName => switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    _ => 'unsupported',
  };
}
