import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protector/src/core/platform/platform_capabilities.dart';
import 'package:protector/src/providers.dart';

class SecurityOnboardingPage extends ConsumerWidget {
  const SecurityOnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(securityControllerProvider);
    final setup = state.setup;
    if (setup == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final controller = ref.read(securityControllerProvider.notifier);
    final capabilities = setup.capabilities;

    return Scaffold(
      appBar: AppBar(title: const Text('Security setup')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Prepare this device before it is lost',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'AntiTheft uses only permissions you approve. It complements the '
              'recovery service already provided by your phone.',
            ),
            const SizedBox(height: 20),
            _OnboardingCard(
              step: '1',
              title: 'Allow recovery notifications',
              description:
                  'Notifications will later report recovery commands and visible '
                  'playback status. Denial is remembered and will not trigger a '
                  'request loop.',
              trailing: _NotificationAction(
                status: capabilities.notificationPermission,
                alreadyRequested: setup.notificationPermissionRequested,
                isBusy: state.isLoading,
                onRequest: controller.requestNotificationPermission,
                onOpenSettings: controller.openAppSettings,
              ),
            ),
            _OnboardingCard(
              step: '2',
              title: 'Review ${capabilities.recoveryServiceName}',
              description:
                  capabilities.nativeRecoveryStateVerifiable
                      ? 'Review the current native recovery configuration.'
                      : 'The operating system does not expose whether this service '
                          'is enabled. Open the official guide and verify it yourself.',
              trailing: FilledButton.tonalIcon(
                onPressed:
                    state.isLoading ? null : controller.openRecoveryGuidance,
                icon: Icon(
                  setup.recoveryGuidanceSeen ? Icons.check : Icons.open_in_new,
                ),
                label: Text(
                  setup.recoveryGuidanceSeen
                      ? 'Guide reviewed'
                      : 'Open official guide',
                ),
              ),
            ),
            _OnboardingCard(
              step: '3',
              title: 'Understand platform limits',
              description: capabilities.limitations.join(' '),
              trailing: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('I understand these limitations'),
                value: setup.limitationsAccepted,
                onChanged:
                    state.isLoading
                        ? null
                        : (value) =>
                            controller.setLimitationsAccepted(value ?? false),
              ),
            ),
            if (state.errorMessage case final message?) ...[
              const SizedBox(height: 8),
              Text(message, style: TextStyle(color: context.errorColor)),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed:
                  setup.canCompleteOnboarding && !state.isLoading
                      ? controller.completeOnboarding
                      : null,
              icon:
                  state.isLoading
                      ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.shield_outlined),
              label: const Text('Finish security setup'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.step,
    required this.title,
    required this.description,
    required this.trailing,
  });

  final String step;
  final String title;
  final String description;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 14, child: Text(step)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(description),
            const SizedBox(height: 12),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _NotificationAction extends StatelessWidget {
  const _NotificationAction({
    required this.status,
    required this.alreadyRequested,
    required this.isBusy,
    required this.onRequest,
    required this.onOpenSettings,
  });

  final PermissionStatus status;
  final bool alreadyRequested;
  final bool isBusy;
  final VoidCallback onRequest;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    if (status == PermissionStatus.granted) {
      return const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.check_circle, color: Colors.green),
        title: Text('Notifications allowed'),
      );
    }
    if (alreadyRequested) {
      return OutlinedButton.icon(
        onPressed: isBusy ? null : onOpenSettings,
        icon: const Icon(Icons.settings_outlined),
        label: const Text('Open app settings'),
      );
    }
    if (status == PermissionStatus.unsupported) {
      return const Text('Notification permission is unavailable here.');
    }
    return FilledButton.tonalIcon(
      onPressed: isBusy ? null : onRequest,
      icon: const Icon(Icons.notifications_outlined),
      label: const Text('Allow notifications'),
    );
  }
}

extension on BuildContext {
  Color get errorColor => Theme.of(this).colorScheme.error;
}
