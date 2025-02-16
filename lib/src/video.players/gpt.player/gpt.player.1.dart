import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_app/src/video.players/steteful.video.player/generate.thumbnails.dart'
    show generateThumbnails;

class GPTPlayerWithTimeline extends StatefulWidget {
  final String videoPath;
  const GPTPlayerWithTimeline({required this.videoPath, Key? key}) : super(key: key);

  @override
  State<GPTPlayerWithTimeline> createState() => _VideoTimelineState();
}

class _VideoTimelineState extends State<GPTPlayerWithTimeline> {
  late VideoPlayerController _controller;
  List<File> thumbnails = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {});
      });

    generateThumbnails(widget.videoPath).then((files) {
      setState(() {
        thumbnails = files;
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        const SizedBox(height: 10),
        isLoading
            ? CircularProgressIndicator()
            : SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: thumbnails.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _controller.seekTo(Duration(seconds: index));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.file(thumbnails[index]),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
