/// return time in mm:ss format from seconds
String formatTime(int secs) {
  final minutes = secs ~/ 60;
  final seconds = secs % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

/// generate download id from packId and imageId
String generateDownloadId(String packId, String imageId) {
  return '${packId}_$imageId';
}
