import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_app/src/extensions/extensions.dart';

import '../dev.player.dart';

class VideoWithOption extends StatefulWidget {
  const VideoWithOption({super.key});
  @override
  State<VideoWithOption> createState() => _VideoWithOptionState();
}

class _VideoWithOptionState extends State<VideoWithOption> {
  bool isPlaying = false;

  double frameRate = 30.0;
  double videoPosition = 0.0;
  Duration videoDuration = Duration.zero;
  bool intaractable = false;

  List<File> thumbnails = [];
  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        frameRate = controller.value.duration.inMilliseconds / controller.value.duration.inSeconds;
        videoDuration = controller.value.duration;
        videoPosition = controller.value.position.inMilliseconds / controller.value.duration.inMilliseconds;
      });
    });
    if (isPlaying) controller.play();
  }

  void seekFrame(int direction) async {
    if (!controller.value.isInitialized) return;
    Duration currentPosition = await controller.position ?? Duration.zero;
    int frameStep = (1000 / frameRate).round(); // Milliseconds per frame
    Duration newPosition = currentPosition + Duration(milliseconds: frameStep * direction);
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > controller.value.duration) {
      newPosition = controller.value.duration;
    }
    controller.seekTo(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () async {
            if (intaractable) {
              setState(() {
                intaractable = !intaractable;
              });
            } else {
              setState(() => intaractable = !intaractable);
              await Future.delayed(Duration(seconds: 3));
              setState(() => intaractable = !intaractable);
            }
          },
          onHorizontalDragUpdate: (details) {
            if (details.primaryDelta! > 0) {
              seekFrame(1); // Forward frame
            } else if (details.primaryDelta! < 0) {
              seekFrame(-1); // Backward frame
            }
          },
          // child: VideoPlayer(controller),
          child: Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
        ),
        if (intaractable)
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 40,
            left: MediaQuery.of(context).size.width / 2 - 40,
            child: IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 50,
              ),
              onPressed: () {
                setState(() {
                  controller.value.isPlaying ? controller.pause() : controller.play();
                  isPlaying = !isPlaying;
                });
              },
            ),
          ),
        // Timeline & Slider at Bottom
        ///rename it to VideoControls
        if (intaractable)
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Slider(
                  value: videoPosition,
                  onChanged: (value) {
                    final newPosition = Duration(milliseconds: (videoDuration.inMilliseconds * value).toInt());
                    print('seekDuraiton $newPosition');
                    controller.seekTo(newPosition);
                    setState(() {
                      videoPosition = value;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        controller.value.position.toTwoDigitsString,
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        videoDuration.toTwoDigitsString,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
