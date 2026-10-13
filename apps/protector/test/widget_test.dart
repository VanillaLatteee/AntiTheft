import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protector/src/app.dart';
import 'package:protector/src/core/platform/platform_capabilities.dart';
import 'package:protector/src/features/siren/domain/recovery_sound.dart';
import 'package:protector/src/providers.dart';

import 'helpers/fakes.dart';

void main() {
  testWidgets('completes onboarding without repeating a denied permission', (
    tester,
  ) async {
    final store = InMemorySecureStore();
    final platform = FakePlatformBridge(
      permissionResult: PermissionStatus.denied,
    );
    final sirenRepository = FakeSirenRepository();
    addTearDown(platform.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStoreProvider.overrideWithValue(store),
          platformBridgeProvider.overrideWithValue(platform),
          sirenRepositoryProvider.overrideWithValue(sirenRepository),
        ],
        child: const AntiTheftApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Security setup'), findsOneWidget);
    await tester.tap(find.text('Allow notifications'));
    await tester.pumpAndSettle();
    expect(platform.permissionRequestCount, 1);
    expect(find.text('Open app settings'), findsOneWidget);

    await tester.ensureVisible(find.text('Open official guide'));
    await tester.tap(find.text('Open official guide'));
    await tester.pumpAndSettle();
    expect(platform.recoveryGuideOpenCount, 1);

    await tester.ensureVisible(find.text('I understand these limitations'));
    await tester.tap(find.text('I understand these limitations'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Finish security setup'));
    await tester.tap(find.text('Finish security setup'));
    await tester.pumpAndSettle();

    expect(find.text('Security readiness'), findsOneWidget);
    expect(platform.permissionRequestCount, 1);
  });

  testWidgets('imports, starts, and immediately stops a local siren', (
    tester,
  ) async {
    final store = InMemorySecureStore({
      'security.onboarding_complete': 'true',
      'security.notification_permission_requested': 'true',
      'security.recovery_guidance_seen': 'true',
      'security.limitations_accepted': 'true',
    });
    final platform = FakePlatformBridge(
      capabilities: const PlatformCapabilities(
        platformName: 'android',
        notificationPermission: PermissionStatus.granted,
        localPlaybackSupported: true,
        backgroundRemotePlaybackSupported: false,
        nativeRecoveryStateVerifiable: false,
        limitations: ['Active app only.'],
      ),
    );
    final sirenRepository =
        FakeSirenRepository()
          ..importResult = const RecoverySound(
            displayName: 'alarm.mp3',
            path: '/private/alarm.mp3',
            sizeBytes: 2048,
            format: AudioFormat.mp3,
          );
    addTearDown(platform.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStoreProvider.overrideWithValue(store),
          platformBridgeProvider.overrideWithValue(platform),
          sirenRepositoryProvider.overrideWithValue(sirenRepository),
        ],
        child: const AntiTheftApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Choose MP3 or WAV'));
    await tester.tap(find.text('Choose MP3 or WAV'));
    await tester.pumpAndSettle();
    expect(find.text('alarm.mp3'), findsOneWidget);

    await tester.ensureVisible(find.text('Play siren for 60 seconds'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play siren for 60 seconds'));
    await tester.pump();

    expect(platform.playRequests, hasLength(1));
    expect(platform.playRequests.single.duration, const Duration(seconds: 60));
    expect(platform.playRequests.single.loop, isTrue);
    expect(find.text('Stop siren'), findsOneWidget);

    await tester.ensureVisible(find.text('Stop siren'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stop siren'));
    await tester.pumpAndSettle();
    expect(platform.stopCount, 1);
    expect(find.text('Play siren for 60 seconds'), findsOneWidget);
  });
}
