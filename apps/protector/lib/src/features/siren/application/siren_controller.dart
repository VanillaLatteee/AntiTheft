import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protector/src/core/platform/platform_bridge.dart';
import 'package:protector/src/features/siren/data/siren_repository.dart';
import 'package:protector/src/features/siren/domain/recovery_sound.dart';

enum PlaybackMode { idle, preview, siren }

final class SirenState {
  const SirenState({
    this.selectedSound,
    this.playbackMode = PlaybackMode.idle,
    this.loopEnabled = true,
    this.isBusy = false,
    this.errorMessage,
  });

  final RecoverySound? selectedSound;
  final PlaybackMode playbackMode;
  final bool loopEnabled;
  final bool isBusy;
  final String? errorMessage;

  bool get isPlaying => playbackMode != PlaybackMode.idle;

  SirenState copyWith({
    RecoverySound? selectedSound,
    bool clearSelectedSound = false,
    PlaybackMode? playbackMode,
    bool? loopEnabled,
    bool? isBusy,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SirenState(
      selectedSound:
          clearSelectedSound ? null : selectedSound ?? this.selectedSound,
      playbackMode: playbackMode ?? this.playbackMode,
      loopEnabled: loopEnabled ?? this.loopEnabled,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final class SirenController extends StateNotifier<SirenState> {
  SirenController(this._repository, this._platformBridge)
    : super(const SirenState(isBusy: true)) {
    _subscription = _platformBridge.audioEvents.listen(
      _handleAudioEvent,
      onError: (Object error) {
        state = state.copyWith(
          playbackMode: PlaybackMode.idle,
          errorMessage: error.toString(),
        );
      },
    );
    load();
  }

  static const previewDuration = Duration(seconds: 10);
  static const sirenDuration = Duration(seconds: 60);

  final SirenRepository _repository;
  final PlatformBridge _platformBridge;
  StreamSubscription<AudioPlaybackEvent>? _subscription;

  Future<void> load() async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      final selected = await _repository.loadSelected();
      state = state.copyWith(
        selectedSound: selected,
        clearSelectedSound: selected == null,
        isBusy: false,
      );
    } on Object catch (error) {
      state = state.copyWith(isBusy: false, errorMessage: error.toString());
    }
  }

  Future<void> importSound() async {
    await stop();
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      final selected = await _repository.importSound();
      state = state.copyWith(
        selectedSound: selected,
        isBusy: false,
        clearError: true,
      );
    } on Object catch (error) {
      state = state.copyWith(isBusy: false, errorMessage: error.toString());
    }
  }

  Future<void> deleteSound() async {
    await stop();
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      await _repository.deleteSelected();
      state = state.copyWith(clearSelectedSound: true, isBusy: false);
    } on Object catch (error) {
      state = state.copyWith(isBusy: false, errorMessage: error.toString());
    }
  }

  void setLoopEnabled(bool enabled) {
    state = state.copyWith(loopEnabled: enabled);
  }

  Future<void> preview() => _play(PlaybackMode.preview);

  Future<void> playSiren() => _play(PlaybackMode.siren);

  Future<void> _play(PlaybackMode mode) async {
    final sound = state.selectedSound;
    if (sound == null || state.isBusy) return;
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      await _platformBridge.playAudio(
        path: sound.path,
        duration:
            mode == PlaybackMode.preview ? previewDuration : sirenDuration,
        loop: mode == PlaybackMode.siren && state.loopEnabled,
      );
      state = state.copyWith(playbackMode: mode, isBusy: false);
    } on Object catch (error) {
      state = state.copyWith(
        playbackMode: PlaybackMode.idle,
        isBusy: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> stop() async {
    if (!state.isPlaying && !state.isBusy) return;
    try {
      await _platformBridge.stopAudio();
    } on Object catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    } finally {
      state = state.copyWith(playbackMode: PlaybackMode.idle, isBusy: false);
    }
  }

  void _handleAudioEvent(AudioPlaybackEvent event) {
    switch (event.status) {
      case AudioPlaybackStatus.playing:
        break;
      case AudioPlaybackStatus.stopped:
      case AudioPlaybackStatus.completed:
        state = state.copyWith(playbackMode: PlaybackMode.idle, isBusy: false);
      case AudioPlaybackStatus.failed:
        state = state.copyWith(
          playbackMode: PlaybackMode.idle,
          isBusy: false,
          errorMessage: event.message ?? 'Audio playback failed.',
        );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
