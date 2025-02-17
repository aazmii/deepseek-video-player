import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_app/src/extensions/extensions.dart';
import 'package:video_player_app/src/video.players/helper.dart';

class DevPlayer extends StatefulWidget {
  final String videoPath;

  const DevPlayer({super.key, required this.videoPath});

  @override
  FrameByFramePlayerState createState() => FrameByFramePlayerState();
}

class FrameByFramePlayerState extends State<DevPlayer> {
  late VideoPlayerController _controller;
  bool isPlaying = false;
  double frameRate = 30.0; // Change based on video FPS
  double videoPosition = 0.0; // Slider position
  Duration videoDuration = Duration.zero; // Total duration of the video
  bool intaractable = false;
  List<File> thumbnails = [];
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          frameRate = _controller.value.duration.inMilliseconds / _controller.value.duration.inSeconds;
          videoDuration = _controller.value.duration;
        });

        _controller.addListener(() {
          setState(() {
            videoPosition = _controller.value.position.inMilliseconds / _controller.value.duration.inMilliseconds;
          });
        });
        getThumbnailsFromVideo();
      });
  }

  Future getThumbnailsFromVideo() async {
    final thumbnails = await getThumbnails(widget.videoPath, _controller.value.duration);
    setState(() {
      this.thumbnails = thumbnails;
    });
  }

  void seekFrame(int direction) async {
    if (!_controller.value.isInitialized) return;
    Duration currentPosition = await _controller.position ?? Duration.zero;
    int frameStep = (1000 / frameRate).round(); // Milliseconds per frame
    Duration newPosition = currentPosition + Duration(milliseconds: frameStep * direction);
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > _controller.value.duration) {
      newPosition = _controller.value.duration;
    }
    _controller.seekTo(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
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
                child: Center(
                  child: _controller.value.isInitialized
                      ? AspectRatio(
                          // aspectRatio: context.acpectRatio,
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : CircularProgressIndicator(),
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
                        _controller.value.isPlaying ? _controller.pause() : _controller.play();
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
                          _controller.seekTo(newPosition);
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
                              _controller.value.position.toTwoDigitsString,
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
          ),
          if (thumbnails.isNotEmpty) Timeline(thumbnails: thumbnails),
          // Text(
          //   '0.00.0',
          //   style: TextStyle(color: Colors.white),
          // )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Timeline extends StatelessWidget {
  const Timeline({super.key, required this.thumbnails});
  final List<File> thumbnails;
  @override
  Widget build(BuildContext context) {
    print(getNumberOfEmptyBoxes(context));
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SizedBox(
            height: 80,
            width: double.infinity,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...List.generate(getNumberOfEmptyBoxes(context), (i) => ThumbnailFrame()),
                ...List.generate(thumbnails.length, (i) => ThumbnailFrame(thumbnail: thumbnails[i], timestamp: i)),
                ...List.generate(getNumberOfEmptyBoxes(context), (i) => ThumbnailFrame()),
              ],
            ),
            // child: ListView.builder(
            //   itemBuilder: (_, i) => ThumbnailFrame(
            //     thumbnail: thumbnails[i],
            //     timestamp: i,
            //   ),
            //   itemCount: thumbnails.length,
            //   scrollDirection: Axis.horizontal,
            // ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: Colors.white,
                height: 90,
                width: 4,
              ),
              Text(
                '0.00.0',
                style: TextStyle(color: Colors.white, fontSize: 12),
              )
            ],
          ),
        ),
      ],
    );
  }

  int getNumberOfEmptyBoxes(BuildContext context) {
    final halfScreen = ((MediaQuery.of(context).size.width / 2)); //100 is thumbnail frame width
    return (halfScreen / 100).floor();
  }
}

class ThumbnailFrame extends StatelessWidget {
  const ThumbnailFrame({super.key, this.thumbnail, this.timestamp});
  final File? thumbnail;
  final int? timestamp;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 20),
      // color: Colors.grey,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            child: thumbnail != null ? Image.file(thumbnail!, fit: BoxFit.cover) : null,
          ),
          Positioned(
            bottom: -20,
            left: -10,
            child: Text(
              // timestamp!.toTwoDigitsString,
              '$timestamp:00',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
          Positioned(
            bottom: -15,
            child: CircleAvatar(
              backgroundColor: Colors.yellow,
              radius: 2,
            ),
          )
        ],
      ),
    );
  }
}
