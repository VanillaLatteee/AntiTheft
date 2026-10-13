import 'package:protector/src/core/platform/platform_capabilities.dart';

final class SecuritySetup {
  const SecuritySetup({
    required this.onboardingComplete,
    required this.notificationPermissionRequested,
    required this.recoveryGuidanceSeen,
    required this.limitationsAccepted,
    required this.capabilities,
  });

  final bool onboardingComplete;
  final bool notificationPermissionRequested;
  final bool recoveryGuidanceSeen;
  final bool limitationsAccepted;
  final PlatformCapabilities capabilities;

  bool get canCompleteOnboarding => recoveryGuidanceSeen && limitationsAccepted;

  int get readyItemCount {
    var count = 0;
    if (capabilities.notificationPermission == PermissionStatus.granted) {
      count++;
    }
    if (recoveryGuidanceSeen) count++;
    if (capabilities.localPlaybackSupported) count++;
    return count;
  }
}
