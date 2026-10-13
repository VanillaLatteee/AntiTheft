import 'dart:typed_data';

import 'package:protector/src/features/siren/domain/recovery_sound.dart';

final class AudioValidationException implements Exception {
  const AudioValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class AudioFileValidator {
  const AudioFileValidator();

  static const maxSizeBytes = 10 * 1024 * 1024;

  AudioFormat validate({
    required String fileName,
    required int declaredSize,
    required Uint8List bytes,
  }) {
    if (declaredSize <= 0 || bytes.isEmpty) {
      throw const AudioValidationException('The selected audio file is empty.');
    }
    if (declaredSize != bytes.length) {
      throw const AudioValidationException(
        'The selected audio file could not be read completely.',
      );
    }
    if (bytes.length > maxSizeBytes) {
      throw const AudioValidationException(
        'The selected file exceeds the 10 MiB limit.',
      );
    }

    final extension = fileName.split('.').last.toLowerCase();
    final signature = _detectFormat(bytes);
    if (signature == null || extension != signature.name) {
      throw const AudioValidationException(
        'Choose a valid MP3 or WAV file. Renamed or corrupt files are rejected.',
      );
    }
    return signature;
  }

  AudioFormat? _detectFormat(Uint8List bytes) {
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x41 &&
        bytes[10] == 0x56 &&
        bytes[11] == 0x45) {
      return AudioFormat.wav;
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0x49 &&
        bytes[1] == 0x44 &&
        bytes[2] == 0x33) {
      return AudioFormat.mp3;
    }
    if (bytes.length >= 2 && bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0) {
      return AudioFormat.mp3;
    }
    return null;
  }
}
