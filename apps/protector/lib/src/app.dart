import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protector/src/features/dashboard/presentation/security_dashboard_page.dart';
import 'package:protector/src/features/security/presentation/security_onboarding_page.dart';
import 'package:protector/src/providers.dart';

class AntiTheftApp extends StatelessWidget {
  const AntiTheftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AntiTheft Protector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const _AppShell(),
    );
  }
}

class _AppShell extends ConsumerStatefulWidget {
  const _AppShell();

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(securityControllerProvider.notifier).refresh();
    } else {
      ref.read(sirenControllerProvider.notifier).stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final security = ref.watch(securityControllerProvider);
    final setup = security.setup;
    if (setup == null) {
      return Scaffold(
        body: Center(
          child:
              security.errorMessage == null
                  ? const CircularProgressIndicator()
                  : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Security status could not be loaded.',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(security.errorMessage!),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed:
                              ref
                                  .read(securityControllerProvider.notifier)
                                  .refresh,
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
        ),
      );
    }
    return setup.onboardingComplete
        ? const SecurityDashboardPage()
        : const SecurityOnboardingPage();
  }
}
