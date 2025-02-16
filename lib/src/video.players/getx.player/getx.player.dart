import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_app/src/extensions/extensions.dart';

import 'controller/toggle.controle.dart';
import 'controller/video.controller.dart';

final _animationDuraiton = Duration(milliseconds: 500);

class GetxPlayer extends StatelessWidget {
  const GetxPlayer({super.key, required this.videoPath});
  final String videoPath;
  @override
  Widget build(BuildContext context) {
    final getController = Get.put(VideoController(videoPath));
    // final getController = Get.find<VideoController>();
    return Scaffold(
      // backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: getController.toggleShowOptions,
            onHorizontalDragUpdate: (details) {
              if (details.primaryDelta! > 0) {
                getController.seekFrame(1); // Forward frame
              } else if (details.primaryDelta! < 0) {
                getController.seekFrame(-1); // Backward frame
              }
            },
            child: Obx(() {
              if (!getController.videoPlayerController.value.isInitialized) {
                return CircularProgressIndicator();
              }
              return AspectRatio(
                // aspectRatio: context.acpectRatio,
                aspectRatio: getController.videoPlayerController.value.aspectRatio,
                child: VideoPlayer(getController.videoPlayerController),
              );
            }),
          ),
          Obx(() => AnimatedOpacity(
                opacity: showVideoControls.value ? 1.0 : 0.0,
                duration: _animationDuraiton,
                child: Positioned(
                  top: MediaQuery.of(context).size.height / 2 - 40,
                  left: MediaQuery.of(context).size.width / 2 - 40,
                  child: IconButton(
                    icon: Icon(
                      getController.video.value.isPlaying == true ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 50,
                    ),
                    onPressed: getController.togglePlay,
                  ),
                ),
              )),
          Obx(
            () => AnimatedOpacity(
              opacity: showVideoControls.value ? 1.0 : 0.0,
              duration: _animationDuraiton,
              child: Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    Slider(
                      value: getController.video.value.videoPosition ?? 0.0,
                      onChanged: getController.onChangeSliderPosition,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getController.videoPlayerController.value.position.toTwoDigitsString,
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            getController.videoPlayerController.value.position.toTwoDigitsString,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
