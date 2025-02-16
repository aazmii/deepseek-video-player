import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

Future<List<File>> generateThumbnails(String videoPath) async {
  List<File> thumbnailFiles = [];
  final tempDir = await getTemporaryDirectory();

  try {
    // Get the total duration of the video
    final VideoPlayerController tempController = VideoPlayerController.asset(videoPath);
    await tempController.initialize();
    final videoDuration = tempController.value.duration.inSeconds;
    tempController.dispose();

    // Generate thumbnails at equal intervals (every 2 seconds)
    for (int i = 0; i < videoDuration; i += 2) {
      final String filePath = '${tempDir.path}/thumb_$i.jpg';

      final Uint8List? thumbnailData = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        timeMs: i * 1000, // Convert seconds to milliseconds
        quality: 75,
      );

      if (thumbnailData != null) {
        final File thumbnailFile = File(filePath);
        await thumbnailFile.writeAsBytes(thumbnailData);
        thumbnailFiles.add(thumbnailFile);
      }
    }
  } catch (e) {
    debugPrint("Error generating thumbnails: $e");
  }

  return thumbnailFiles;
}
