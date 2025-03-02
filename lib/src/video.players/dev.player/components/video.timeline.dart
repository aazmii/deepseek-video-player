import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player_app/src/extensions/extensions.dart';
// import 'package:get/get_utils/src/extensions/export.dart';
import 'package:video_player_app/src/video.players/dev.player/dev.player.dart';

import 'thumbnail.frame.dart';

const thumbnailWidth = 100.0;

class VideoTimeline extends StatefulWidget {
  const VideoTimeline({super.key, required this.thumbnails, required this.videoPath});
  final List<File> thumbnails;
  final String videoPath;
  @override
  State<VideoTimeline> createState() => _VideoTimelineState();
}

class _VideoTimelineState extends State<VideoTimeline> {
  final int frameIntervalMs = 500; // Thumbnails every 500ms
  late ScrollController _scrollController;
  // Timer? _scrollTimer;
  Duration? seekDuration;
  void _syncScroll() {
    if (!controller.value.isPlaying) return;

    double currentPositionMs = controller.value.position.inMilliseconds.toDouble();

    // Ensure frameIntervalMs isn't zero to avoid division by zero
    if (frameIntervalMs == 0) return;

    // Map video position to scroll offset
    double scrollOffset = (currentPositionMs / frameIntervalMs) * thumbnailWidth;

    // Clamp to avoid overscrolling
    double maxScrollExtent = _scrollController.position.maxScrollExtent;
    scrollOffset = scrollOffset.clamp(0, maxScrollExtent);

    // If the offset difference is large, use jumpTo; otherwise, animate for smooth movement
    if ((_scrollController.offset - scrollOffset).abs() > thumbnailWidth * 2) {
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

    _scrollController.addListener(() {
      setState(() => seekDuration = _fromPercentageToDuration(_scrollPercentage()));
      if (seekDuration != null) controller.seekTo(seekDuration!);
    });
    _syncScroll; //to avoid lints 
    // controller.addListener(_syncScroll);
  }

  double _scrollPercentage() {
    final trimmed = ((_scrollController.offset / (thumbnailWidth * widget.thumbnails.length)) * 100).toStringAsFixed(3);
    final parsed = double.parse(trimmed);
    return parsed > 100.0 ? 100 : parsed;
  }

  Duration _fromPercentageToDuration(double scrollPercentage) {
    return Duration(milliseconds: (controller.value.duration.inMilliseconds * (scrollPercentage / 100)).toInt());
  }

  @override
  Widget build(BuildContext context) {
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
              itemBuilder: (_, i) => Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? context.width / 2 : 0,
                  right: i == widget.thumbnails.length - 1 ? context.width / 2 : 0,
                ),
                child: ThumbnailFrame(thumbnail: widget.thumbnails[i], timestamp: i),
              ),
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
                controller.value.position.formatInHMS,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
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
