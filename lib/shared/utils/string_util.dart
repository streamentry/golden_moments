/// return time in mm:ss format from seconds
String formatTime(int secs) {
  final minutes = secs ~/ 60;
  final seconds = secs % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

/// generate download id from packId and imageId
String generateDownloadId(String packId, String imageId) {
  return '${packId}_$imageId';
}

/// Convert a size string like '23 MB' or '23 GB' into bytes
int parseSizeToBytes(String size) {
  // Corrected the regular expression to remove the escaped dollar sign
  final sizePattern = RegExp(r'^(\d+(\.\d+)?)\s*(KB|MB|GB|TB)$');
  final match = sizePattern.firstMatch(size.trim().toUpperCase());

  if (match == null) {
    throw ArgumentError('Invalid size format: $size');
  }

  final value = double.parse(match.group(1)!);
  final unit = match.group(3);

  switch (unit) {
    case 'KB':
      return (value * 1024).toInt();
    case 'MB':
      return (value * 1024 * 1024).toInt();
    case 'GB':
      return (value * 1024 * 1024 * 1024).toInt();
    case 'TB':
      return (value * 1024 * 1024 * 1024 * 1024).toInt();
    default:
      throw ArgumentError('Unsupported size unit: $unit');
  }
}
