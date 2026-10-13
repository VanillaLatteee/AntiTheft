import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protector/src/features/siren/application/siren_controller.dart';
import 'package:protector/src/providers.dart';

class SirenConfigurationCard extends ConsumerWidget {
  const SirenConfigurationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sirenControllerProvider);
    final controller = ref.read(sirenControllerProvider.notifier);
    final sound = state.selectedSound;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.campaign_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Custom recovery siren',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Import a valid MP3 or WAV up to 10 MiB. The app copies it into '
              'private storage; the original file is not modified.',
            ),
            const SizedBox(height: 14),
            if (state.isBusy && sound == null)
              const Center(child: CircularProgressIndicator())
            else if (sound == null)
              OutlinedButton.icon(
                onPressed: state.isBusy ? null : controller.importSound,
                icon: const Icon(Icons.audio_file_outlined),
                label: const Text('Choose MP3 or WAV'),
              )
            else ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.library_music_outlined),
                title: Text(sound.displayName),
                subtitle: Text(
                  '${sound.format.name.toUpperCase()} • ${sound.formattedSize}',
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed:
                        state.isBusy || state.isPlaying
                            ? null
                            : controller.preview,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Preview 10s'),
                  ),
                  OutlinedButton.icon(
                    onPressed: state.isBusy ? null : controller.importSound,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Replace'),
                  ),
                  TextButton.icon(
                    onPressed: state.isBusy ? null : controller.deleteSound,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Loop shorter audio'),
                subtitle: const Text(
                  'Looping stops automatically at the 60-second target.',
                ),
                value: state.loopEnabled,
                onChanged:
                    state.isBusy || state.isPlaying
                        ? null
                        : controller.setLoopEnabled,
              ),
              const Text(
                'Playback uses normal media audio policy. Device volume, audio '
                'focus, interruptions, and OS restrictions still apply.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              if (state.isPlaying)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: controller.stop,
                  icon: const Icon(Icons.stop),
                  label: Text(
                    state.playbackMode == PlaybackMode.preview
                        ? 'Stop preview'
                        : 'Stop siren',
                  ),
                )
              else
                FilledButton.icon(
                  onPressed: state.isBusy ? null : controller.playSiren,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Play siren for 60 seconds'),
                ),
            ],
            if (state.errorMessage case final message?) ...[
              const SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
