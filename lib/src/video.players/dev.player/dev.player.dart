import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_app/src/video.players/helper.dart';

import 'components/video.options.dart';
import 'components/video.timeline.dart';

late VideoPlayerController controller;

class DevPlayerScreen extends StatefulWidget {
  final String videoPath;

  const DevPlayerScreen({super.key, required this.videoPath});

  @override
  FrameByFramePlayerState createState() => FrameByFramePlayerState();
}

class FrameByFramePlayerState extends State<DevPlayerScreen> {
  List<File> thumbnails = [];
  bool get isLoadComplete => controller.value.isInitialized && thumbnails.isNotEmpty;
  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath))
      ..initialize().then((_) {
        getThumbnailsFromVideo();
      });
  }

  Future getThumbnailsFromVideo() async {
    final thumbnails = await getThumbnails(widget.videoPath, controller.value.duration);
    setState(() => this.thumbnails = thumbnails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      body: !isLoadComplete
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(flex: 6, child: VideoWithOption()),
                Expanded(child: VideoTimeline(thumbnails: thumbnails, videoPath: widget.videoPath)),
              ],
            ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
