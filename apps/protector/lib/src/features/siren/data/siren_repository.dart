import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protector/src/core/storage/secure_store.dart';
import 'package:protector/src/features/siren/domain/audio_file_validator.dart';
import 'package:protector/src/features/siren/domain/recovery_sound.dart';

final class PickedAudioFile {
  const PickedAudioFile({
    required this.name,
    required this.size,
    required this.bytes,
  });

  final String name;
  final int size;
  final Uint8List bytes;
}

abstract interface class AudioFilePicker {
  Future<PickedAudioFile?> pickAudio();
}

final class SystemAudioFilePicker implements AudioFilePicker {
  @override
  Future<PickedAudioFile?> pickAudio() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mp3', 'wav'],
      allowMultiple: false,
      withData: true,
    );
    if (result == null) return null;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      throw const AudioValidationException(
        'The selected file could not be loaded.',
      );
    }
    return PickedAudioFile(name: file.name, size: file.size, bytes: bytes);
  }
}

abstract interface class SirenRepository {
  Future<RecoverySound?> loadSelected();

  Future<RecoverySound?> importSound();

  Future<void> deleteSelected();
}

typedef AppDirectoryProvider = Future<Directory> Function();

final class LocalSirenRepository implements SirenRepository {
  LocalSirenRepository({
    required SecureStore store,
    required AudioFilePicker filePicker,
    AppDirectoryProvider? directoryProvider,
    AudioFileValidator validator = const AudioFileValidator(),
  }) : _store = store,
       _filePicker = filePicker,
       _directoryProvider =
           directoryProvider ?? getApplicationDocumentsDirectory,
       _validator = validator;

  static const _metadataKey = 'siren.selected_audio';
  static const _directoryName = 'recovery_audio';

  final SecureStore _store;
  final AudioFilePicker _filePicker;
  final AppDirectoryProvider _directoryProvider;
  final AudioFileValidator _validator;

  @override
  Future<RecoverySound?> loadSelected() async {
    final encoded = await _store.read(_metadataKey);
    if (encoded == null) return null;
    try {
      final sound = RecoverySound.fromJson(
        Map<String, Object?>.from(jsonDecode(encoded) as Map),
      );
      if (!await File(sound.path).exists()) {
        await _store.delete(_metadataKey);
        return null;
      }
      return sound;
    } on Object {
      await _store.delete(_metadataKey);
      return null;
    }
  }

  @override
  Future<RecoverySound?> importSound() async {
    final selected = await _filePicker.pickAudio();
    if (selected == null) return null;
    final format = _validator.validate(
      fileName: selected.name,
      declaredSize: selected.size,
      bytes: selected.bytes,
    );

    final root = await _directoryProvider();
    final directory = Directory(
      '${root.path}${Platform.pathSeparator}$_directoryName',
    );
    await directory.create(recursive: true);
    final target = File(
      '${directory.path}${Platform.pathSeparator}siren.${format.name}',
    );
    final temporary = File('${target.path}.tmp');

    try {
      await temporary.writeAsBytes(selected.bytes, flush: true);
      await _deleteAudioFiles(directory, except: temporary.path);
      await temporary.rename(target.path);
    } on Object {
      if (await temporary.exists()) await temporary.delete();
      rethrow;
    }

    final sound = RecoverySound(
      displayName: selected.name,
      path: target.path,
      sizeBytes: selected.bytes.length,
      format: format,
    );
    await _store.write(_metadataKey, jsonEncode(sound.toJson()));
    return sound;
  }

  @override
  Future<void> deleteSelected() async {
    final root = await _directoryProvider();
    final directory = Directory(
      '${root.path}${Platform.pathSeparator}$_directoryName',
    );
    if (await directory.exists()) await _deleteAudioFiles(directory);
    await _store.delete(_metadataKey);
  }

  Future<void> _deleteAudioFiles(Directory directory, {String? except}) async {
    for (final extension in AudioFormat.values.map((value) => value.name)) {
      final file = File(
        '${directory.path}${Platform.pathSeparator}siren.$extension',
      );
      if (file.path != except && await file.exists()) await file.delete();
      final temporary = File('${file.path}.tmp');
      if (temporary.path != except && await temporary.exists()) {
        await temporary.delete();
      }
    }
  }
}
