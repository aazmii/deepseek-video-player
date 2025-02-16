import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StatefulVideoPlayer extends StatefulWidget {
  final String videoPath;

  const StatefulVideoPlayer({super.key, required this.videoPath});

  @override
  FrameByFramePlayerState createState() => FrameByFramePlayerState();
}

class FrameByFramePlayerState extends State<StatefulVideoPlayer> {
  late VideoPlayerController _controller;
  bool isPlaying = false;
  double frameRate = 30.0; // Change based on video FPS
  double videoPosition = 0.0; // Slider position
  Duration videoDuration = Duration.zero; // Total duration of the video
  bool intaractable = false;
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
      // backgroundColor: Colors.black,
      body: Stack(
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
                          _formatDuration(_controller.value.position),
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          _formatDuration(videoDuration),
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
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

extension ContextExt on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  bool get isPotrait => mediaQuery.orientation == Orientation.portrait;
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
  double get acpectRatio => screenWidth / screenHeight;
}
