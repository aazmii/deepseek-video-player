import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_app/src/extensions/extensions.dart';
import 'package:video_player_app/src/video.players/helper.dart';

late VideoPlayerController _controller;
const _thumbnailWidth = 100.0;

class DevPlayerScreen extends StatefulWidget {
  final String videoPath;

  const DevPlayerScreen({super.key, required this.videoPath});

  @override
  FrameByFramePlayerState createState() => FrameByFramePlayerState();
}

class FrameByFramePlayerState extends State<DevPlayerScreen> {
  List<File> thumbnails = [];
  bool get isLoadComplete => _controller.value.isInitialized && thumbnails.isNotEmpty;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath))
      ..initialize().then((_) {
        getThumbnailsFromVideo();
      });
  }

  Future getThumbnailsFromVideo() async {
    final thumbnails = await getThumbnails(widget.videoPath, _controller.value.duration);
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
                VideoWithOption(),
                if (thumbnails.isNotEmpty) VideoTimeline(thumbnails: thumbnails),
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

class VideoWithOption extends StatefulWidget {
  const VideoWithOption({super.key});
  @override
  State<VideoWithOption> createState() => _VideoWithOptionState();
}

class _VideoWithOptionState extends State<VideoWithOption> {
  bool isPlaying = true;

  double frameRate = 30.0;
  double videoPosition = 0.0;
  Duration videoDuration = Duration.zero;
  bool intaractable = false;

  List<File> thumbnails = [];
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        frameRate = _controller.value.duration.inMilliseconds / _controller.value.duration.inSeconds;
        videoDuration = _controller.value.duration;
        videoPosition = _controller.value.position.inMilliseconds / _controller.value.duration.inMilliseconds;
      });
    });
    _controller.play();
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
    // _controller.play();
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
          child: Center(
              child: AspectRatio(
            // aspectRatio: context.acpectRatio,
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )),
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
    );
  }
}

class VideoTimeline extends StatefulWidget {
  const VideoTimeline({super.key, required this.thumbnails});
  final List<File> thumbnails;

  @override
  State<VideoTimeline> createState() => _VideoTimelineState();
}

class _VideoTimelineState extends State<VideoTimeline> {
  final int frameIntervalMs = 500; // Thumbnails every 500ms
  late ScrollController _scrollController;
  // Timer? _scrollTimer;

  void _syncScroll() {
    if (!_controller.value.isPlaying) return;

    double currentPositionMs = _controller.value.position.inMilliseconds.toDouble();

    // Ensure frameIntervalMs isn't zero to avoid division by zero
    if (frameIntervalMs == 0) return;

    // Map video position to scroll offset
    double scrollOffset = (currentPositionMs / frameIntervalMs) * _thumbnailWidth;

    // Clamp to avoid overscrolling
    double maxScrollExtent = _scrollController.position.maxScrollExtent;
    scrollOffset = scrollOffset.clamp(0, maxScrollExtent);

    // If the offset difference is large, use jumpTo; otherwise, animate for smooth movement
    if ((_scrollController.offset - scrollOffset).abs() > _thumbnailWidth * 2) {
      _scrollController.jumpTo(scrollOffset);
    } else {
      _scrollController.animateTo(
        scrollOffset,
        duration: Duration(milliseconds: 300), // Slightly slower for smoothness
        curve: Curves.linear,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller.addListener(_syncScroll);
  }

  @override
  Widget build(BuildContext context) {
    // print(getNumberOfEmptyBoxes(context));
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SizedBox(
            height: 80,
            width: double.infinity,
            child: ListView.builder(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              itemCount: widget.thumbnails.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Row(
                    children: [
                      SizedBox(width: context.width / 2),
                      _ThumbnailFrame(thumbnail: widget.thumbnails[i], timestamp: i)
                    ],
                  );
                } else if (i == widget.thumbnails.length - 1) {
                  return Row(
                    children: [
                      _ThumbnailFrame(thumbnail: widget.thumbnails[i - 1], timestamp: i - 1),
                      SizedBox(width: context.width / 2),
                    ],
                  );
                } else {
                  return _ThumbnailFrame(thumbnail: widget.thumbnails[i], timestamp: i);
                }
              },
            ),
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _ThumbnailFrame extends StatelessWidget {
  const _ThumbnailFrame({this.thumbnail, this.timestamp});
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
            width: _thumbnailWidth,
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
