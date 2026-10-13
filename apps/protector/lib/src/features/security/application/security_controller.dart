import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protector/src/features/security/data/security_repository.dart';
import 'package:protector/src/features/security/domain/security_setup.dart';

final class SecurityState {
  const SecurityState({this.setup, this.isLoading = false, this.errorMessage});

  const SecurityState.loading() : this(isLoading: true);

  final SecuritySetup? setup;
  final bool isLoading;
  final String? errorMessage;

  SecurityState copyWith({
    SecuritySetup? setup,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SecurityState(
      setup: setup ?? this.setup,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final class SecurityController extends StateNotifier<SecurityState> {
  SecurityController(this._repository) : super(const SecurityState.loading()) {
    refresh();
  }

  final SecurityRepository _repository;

  Future<void> refresh() => _run(_repository.load);

  Future<void> requestNotificationPermission() =>
      _run(_repository.requestNotificationPermission);

  Future<void> openRecoveryGuidance() => _run(_repository.openRecoveryGuidance);

  Future<void> setLimitationsAccepted(bool accepted) =>
      _run(() => _repository.setLimitationsAccepted(accepted));

  Future<void> completeOnboarding() => _run(_repository.completeOnboarding);

  Future<void> openAppSettings() async {
    try {
      await _repository.openAppSettings();
    } on Object catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<void> _run(Future<SecuritySetup> Function() operation) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final setup = await operation();
      state = SecurityState(setup: setup);
    } on Object catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }
}
