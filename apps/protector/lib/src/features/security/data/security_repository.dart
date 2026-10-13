import 'package:protector/src/core/platform/platform_bridge.dart';
import 'package:protector/src/core/storage/secure_store.dart';
import 'package:protector/src/features/security/domain/security_setup.dart';

abstract interface class SecurityRepository {
  Future<SecuritySetup> load();

  Future<SecuritySetup> requestNotificationPermission();

  Future<SecuritySetup> openRecoveryGuidance();

  Future<SecuritySetup> setLimitationsAccepted(bool accepted);

  Future<SecuritySetup> completeOnboarding();

  Future<void> openAppSettings();
}

final class SecureSecurityRepository implements SecurityRepository {
  SecureSecurityRepository(this._store, this._platformBridge);

  static const _onboardingCompleteKey = 'security.onboarding_complete';
  static const _notificationRequestedKey =
      'security.notification_permission_requested';
  static const _recoveryGuidanceSeenKey = 'security.recovery_guidance_seen';
  static const _limitationsAcceptedKey = 'security.limitations_accepted';

  final SecureStore _store;
  final PlatformBridge _platformBridge;

  @override
  Future<SecuritySetup> load() async {
    final values = await Future.wait<String?>([
      _store.read(_onboardingCompleteKey),
      _store.read(_notificationRequestedKey),
      _store.read(_recoveryGuidanceSeenKey),
      _store.read(_limitationsAcceptedKey),
    ]);
    final capabilities = await _platformBridge.getCapabilities();
    return SecuritySetup(
      onboardingComplete: values[0] == 'true',
      notificationPermissionRequested: values[1] == 'true',
      recoveryGuidanceSeen: values[2] == 'true',
      limitationsAccepted: values[3] == 'true',
      capabilities: capabilities,
    );
  }

  @override
  Future<SecuritySetup> requestNotificationPermission() async {
    if (await _store.read(_notificationRequestedKey) == 'true') {
      return load();
    }
    await _store.write(_notificationRequestedKey, 'true');
    await _platformBridge.requestNotificationPermission();
    return load();
  }

  @override
  Future<SecuritySetup> openRecoveryGuidance() async {
    await _platformBridge.openNativeRecoveryGuide();
    await _store.write(_recoveryGuidanceSeenKey, 'true');
    return load();
  }

  @override
  Future<SecuritySetup> setLimitationsAccepted(bool accepted) async {
    await _store.write(_limitationsAcceptedKey, accepted.toString());
    return load();
  }

  @override
  Future<SecuritySetup> completeOnboarding() async {
    final setup = await load();
    if (!setup.canCompleteOnboarding) {
      throw StateError('Recovery guidance and limitations must be reviewed.');
    }
    await _store.write(_onboardingCompleteKey, 'true');
    return load();
  }

  @override
  Future<void> openAppSettings() => _platformBridge.openAppSettings();
}
