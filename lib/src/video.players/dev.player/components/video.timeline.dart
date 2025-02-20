import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player_app/src/extensions/extensions.dart';

class VideoTimeline extends StatelessWidget {
  const VideoTimeline({super.key, required this.thumbnails});
  final List<File> thumbnails;
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
              physics: BouncingScrollPhysics(),
              itemCount: thumbnails.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Row(
                    children: [
                      SizedBox(width: context.width / 2),
                      _ThumbnailFrame(thumbnail: thumbnails[i], timestamp: i)
                    ],
                  );
                } else if (i == thumbnails.length - 1) {
                  return Row(
                    children: [
                      _ThumbnailFrame(thumbnail: thumbnails[i - 1], timestamp: i - 1),
                      SizedBox(width: context.width / 2),
                    ],
                  );
                } else {
                  return _ThumbnailFrame(thumbnail: thumbnails[i], timestamp: i);
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

  int getNumberOfEmptyBoxes(BuildContext context) {
    final halfScreen = ((MediaQuery.of(context).size.width / 2)); //100 is thumbnail frame width
    return (halfScreen / 100).floor();
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
