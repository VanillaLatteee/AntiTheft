import 'package:flutter_test/flutter_test.dart';
import 'package:protector/src/core/platform/platform_capabilities.dart';
import 'package:protector/src/features/security/data/security_repository.dart';

import 'helpers/fakes.dart';

void main() {
  test('persists denial and never repeats a notification request', () async {
    final store = InMemorySecureStore();
    final platform = FakePlatformBridge(
      permissionResult: PermissionStatus.denied,
    );
    final repository = SecureSecurityRepository(store, platform);

    final first = await repository.requestNotificationPermission();
    final second = await repository.requestNotificationPermission();

    expect(first.notificationPermissionRequested, isTrue);
    expect(second.notificationPermissionRequested, isTrue);
    expect(platform.permissionRequestCount, 1);
  });

  test(
    'requires guidance and limitation acknowledgement before completion',
    () async {
      final store = InMemorySecureStore();
      final platform = FakePlatformBridge();
      final repository = SecureSecurityRepository(store, platform);

      await expectLater(repository.completeOnboarding(), throwsStateError);

      await repository.openRecoveryGuidance();
      await repository.setLimitationsAccepted(true);
      final completed = await repository.completeOnboarding();

      expect(platform.recoveryGuideOpenCount, 1);
      expect(completed.onboardingComplete, isTrue);
    },
  );
}
