import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protector/src/core/platform/platform_bridge.dart';
import 'package:protector/src/core/storage/secure_store.dart';
import 'package:protector/src/features/security/application/security_controller.dart';
import 'package:protector/src/features/security/data/security_repository.dart';
import 'package:protector/src/features/siren/application/siren_controller.dart';
import 'package:protector/src/features/siren/data/siren_repository.dart';

final secureStoreProvider = Provider<SecureStore>(
  (ref) => PlatformSecureStore(),
);

final platformBridgeProvider = Provider<PlatformBridge>(
  (ref) => MethodChannelPlatformBridge(),
);

final securityRepositoryProvider = Provider<SecurityRepository>(
  (ref) => SecureSecurityRepository(
    ref.watch(secureStoreProvider),
    ref.watch(platformBridgeProvider),
  ),
);

final securityControllerProvider =
    StateNotifierProvider<SecurityController, SecurityState>(
      (ref) => SecurityController(ref.watch(securityRepositoryProvider)),
    );

final sirenRepositoryProvider = Provider<SirenRepository>(
  (ref) => LocalSirenRepository(
    store: ref.watch(secureStoreProvider),
    filePicker: SystemAudioFilePicker(),
  ),
);

final sirenControllerProvider =
    StateNotifierProvider<SirenController, SirenState>(
      (ref) => SirenController(
        ref.watch(sirenRepositoryProvider),
        ref.watch(platformBridgeProvider),
      ),
    );
