enum PermissionStatus {
  notDetermined,
  granted,
  denied,
  restricted,
  unsupported,
  unknown;

  static PermissionStatus fromWireValue(Object? value) {
    return switch (value) {
      'notDetermined' => PermissionStatus.notDetermined,
      'granted' || 'provisional' => PermissionStatus.granted,
      'denied' => PermissionStatus.denied,
      'restricted' => PermissionStatus.restricted,
      'unsupported' => PermissionStatus.unsupported,
      _ => PermissionStatus.unknown,
    };
  }
}

final class PlatformCapabilities {
  const PlatformCapabilities({
    required this.platformName,
    required this.notificationPermission,
    required this.localPlaybackSupported,
    required this.backgroundRemotePlaybackSupported,
    required this.nativeRecoveryStateVerifiable,
    required this.limitations,
    this.batteryOptimizationExempt,
  });

  factory PlatformCapabilities.fromMap(Map<Object?, Object?> map) {
    return PlatformCapabilities(
      platformName: map['platform'] as String? ?? 'unknown',
      notificationPermission: PermissionStatus.fromWireValue(
        map['notificationPermission'],
      ),
      localPlaybackSupported: map['localPlaybackSupported'] == true,
      backgroundRemotePlaybackSupported:
          map['backgroundRemotePlaybackSupported'] == true,
      nativeRecoveryStateVerifiable:
          map['nativeRecoveryStateVerifiable'] == true,
      batteryOptimizationExempt: map['batteryOptimizationExempt'] as bool?,
      limitations:
          (map['limitations'] as List<Object?>?)?.whereType<String>().toList(
            growable: false,
          ) ??
          const [],
    );
  }

  factory PlatformCapabilities.unavailable(String platformName) {
    return PlatformCapabilities(
      platformName: platformName,
      notificationPermission: PermissionStatus.unsupported,
      localPlaybackSupported: false,
      backgroundRemotePlaybackSupported: false,
      nativeRecoveryStateVerifiable: false,
      limitations: const [
        'Native capabilities are unavailable in this environment.',
      ],
    );
  }

  final String platformName;
  final PermissionStatus notificationPermission;
  final bool localPlaybackSupported;
  final bool backgroundRemotePlaybackSupported;
  final bool nativeRecoveryStateVerifiable;
  final bool? batteryOptimizationExempt;
  final List<String> limitations;

  String get recoveryServiceName => switch (platformName) {
    'android' => 'Google Find Hub',
    'ios' => 'Apple Find My',
    _ => 'native recovery service',
  };
}
