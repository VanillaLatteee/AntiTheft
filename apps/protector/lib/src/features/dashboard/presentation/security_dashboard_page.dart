import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protector/src/core/platform/platform_capabilities.dart';
import 'package:protector/src/features/siren/presentation/siren_configuration_card.dart';
import 'package:protector/src/providers.dart';

class SecurityDashboardPage extends ConsumerWidget {
  const SecurityDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final security = ref.watch(securityControllerProvider);
    final setup = security.setup;
    if (setup == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final capabilities = setup.capabilities;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AntiTheft Protector'),
        actions: [
          IconButton(
            tooltip: 'Refresh security status',
            onPressed:
                security.isLoading
                    ? null
                    : ref.read(securityControllerProvider.notifier).refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: ref.read(securityControllerProvider.notifier).refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Security readiness',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${setup.readyItemCount} of 3 available protections are ready',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              _ReadinessCard(
                icon: Icons.notifications_outlined,
                title: 'Recovery notifications',
                status: _notificationStatus(
                  capabilities.notificationPermission,
                ),
                ready:
                    capabilities.notificationPermission ==
                    PermissionStatus.granted,
                action:
                    capabilities.notificationPermission ==
                            PermissionStatus.granted
                        ? null
                        : TextButton(
                          onPressed:
                              ref
                                  .read(securityControllerProvider.notifier)
                                  .openAppSettings,
                          child: const Text('Open settings'),
                        ),
              ),
              _ReadinessCard(
                icon: Icons.travel_explore,
                title: capabilities.recoveryServiceName,
                status:
                    setup.recoveryGuidanceSeen
                        ? 'Guide reviewed; verify the service in its own settings.'
                        : 'Not reviewed',
                ready: setup.recoveryGuidanceSeen,
                action: TextButton(
                  onPressed:
                      ref
                          .read(securityControllerProvider.notifier)
                          .openRecoveryGuidance,
                  child: const Text('Open guide'),
                ),
              ),
              _ReadinessCard(
                icon: Icons.volume_up_outlined,
                title: 'Local recovery siren',
                status:
                    capabilities.localPlaybackSupported
                        ? 'Available while the app is active'
                        : 'Unavailable on this platform',
                ready: capabilities.localPlaybackSupported,
              ),
              if (capabilities.batteryOptimizationExempt == false)
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.battery_alert_outlined),
                    title: Text('Battery optimization is active'),
                    subtitle: Text(
                      'This does not block active local playback, but may affect '
                      'future remote delivery. AntiTheft does not change it silently.',
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              const SirenConfigurationCard(),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Platform limits',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      for (final limitation in capabilities.limitations)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('• $limitation'),
                        ),
                    ],
                  ),
                ),
              ),
              if (security.errorMessage case final message?)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _notificationStatus(PermissionStatus status) => switch (status) {
    PermissionStatus.granted => 'Allowed',
    PermissionStatus.denied => 'Denied; enable it in system settings',
    PermissionStatus.notDetermined => 'Not requested',
    PermissionStatus.restricted => 'Restricted by the operating system',
    PermissionStatus.unsupported => 'Unsupported',
    PermissionStatus.unknown => 'Status unavailable',
  };
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({
    required this.icon,
    required this.title,
    required this.status,
    required this.ready,
    this.action,
  });

  final IconData icon;
  final String title;
  final String status;
  final bool ready;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(status),
        trailing:
            action ??
            Icon(
              ready ? Icons.check_circle : Icons.warning_amber,
              color: ready ? Colors.green : Colors.amber.shade800,
            ),
      ),
    );
  }
}
