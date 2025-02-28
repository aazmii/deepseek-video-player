import 'dart:io';

import 'package:flutter/material.dart';

import 'video.timeline.dart';

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
            width: thumbnailWidth,
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
