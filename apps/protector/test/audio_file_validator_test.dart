import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:protector/src/features/siren/domain/audio_file_validator.dart';
import 'package:protector/src/features/siren/domain/recovery_sound.dart';

void main() {
  const validator = AudioFileValidator();

  test('accepts MP3 and WAV signatures when extension matches', () {
    final mp3 = Uint8List.fromList([0x49, 0x44, 0x33, 0, 0, 0]);
    final wav = Uint8List.fromList([
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
    ]);

    expect(
      validator.validate(
        fileName: 'alarm.MP3',
        declaredSize: mp3.length,
        bytes: mp3,
      ),
      AudioFormat.mp3,
    );
    expect(
      validator.validate(
        fileName: 'alarm.wav',
        declaredSize: wav.length,
        bytes: wav,
      ),
      AudioFormat.wav,
    );
  });

  test('rejects renamed, incomplete, empty, and oversized files', () {
    final mp3 = Uint8List.fromList([0x49, 0x44, 0x33, 0]);

    expect(
      () => validator.validate(
        fileName: 'renamed.wav',
        declaredSize: mp3.length,
        bytes: mp3,
      ),
      throwsA(isA<AudioValidationException>()),
    );
    expect(
      () => validator.validate(
        fileName: 'partial.mp3',
        declaredSize: mp3.length + 1,
        bytes: mp3,
      ),
      throwsA(isA<AudioValidationException>()),
    );
    expect(
      () => validator.validate(
        fileName: 'empty.mp3',
        declaredSize: 0,
        bytes: Uint8List(0),
      ),
      throwsA(isA<AudioValidationException>()),
    );
    final oversized = Uint8List(AudioFileValidator.maxSizeBytes + 1)
      ..setAll(0, [0x49, 0x44, 0x33]);
    expect(
      () => validator.validate(
        fileName: 'large.mp3',
        declaredSize: oversized.length,
        bytes: oversized,
      ),
      throwsA(isA<AudioValidationException>()),
    );
  });
}
