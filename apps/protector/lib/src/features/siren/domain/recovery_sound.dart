final class RecoverySound {
  const RecoverySound({
    required this.displayName,
    required this.path,
    required this.sizeBytes,
    required this.format,
  });

  factory RecoverySound.fromJson(Map<String, Object?> json) {
    return RecoverySound(
      displayName: json['displayName'] as String,
      path: json['path'] as String,
      sizeBytes: json['sizeBytes'] as int,
      format: AudioFormat.values.byName(json['format'] as String),
    );
  }

  final String displayName;
  final String path;
  final int sizeBytes;
  final AudioFormat format;

  Map<String, Object?> toJson() => {
    'displayName': displayName,
    'path': path,
    'sizeBytes': sizeBytes,
    'format': format.name,
  };

  String get formattedSize {
    final mebibytes = sizeBytes / (1024 * 1024);
    if (mebibytes >= 1) return '${mebibytes.toStringAsFixed(1)} MiB';
    return '${(sizeBytes / 1024).toStringAsFixed(0)} KiB';
  }
}

enum AudioFormat { mp3, wav }
