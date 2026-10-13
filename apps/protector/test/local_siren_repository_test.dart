import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:protector/src/features/siren/data/siren_repository.dart';

import 'helpers/fakes.dart';

void main() {
  test(
    'copies validated audio privately, restores metadata, and deletes it',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'antitheft-siren-test-',
      );
      addTearDown(() => root.delete(recursive: true));
      final store = InMemorySecureStore();
      final picker = FakeAudioFilePicker(
        PickedAudioFile(
          name: 'recovery.wav',
          size: 12,
          bytes: Uint8List.fromList([
            0x52,
            0x49,
            0x46,
            0x46,
            0,
            0,
            0,
            0,
            0x57,
            0x41,
            0x56,
            0x45,
          ]),
        ),
      );
      final repository = LocalSirenRepository(
        store: store,
        filePicker: picker,
        directoryProvider: () async => root,
      );

      final imported = await repository.importSound();

      expect(imported, isNotNull);
      expect(imported!.path, contains('recovery_audio'));
      expect(await File(imported.path).exists(), isTrue);
      expect((await File(imported.path).readAsBytes()).length, 12);

      final restored =
          await LocalSirenRepository(
            store: store,
            filePicker: picker,
            directoryProvider: () async => root,
          ).loadSelected();
      expect(restored?.displayName, 'recovery.wav');

      await repository.deleteSelected();
      expect(await File(imported.path).exists(), isFalse);
      expect(await repository.loadSelected(), isNull);
    },
  );
}
