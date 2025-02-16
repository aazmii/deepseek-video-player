import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../model/vidoe.controller.model.dart';
import 'toggle.controle.dart';

class VideoController extends GetxController {
  late VideoPlayerController videoPlayerController;

  var video = Rx<VideoControllerModel>(VideoControllerModel(videoPath: ''));

  VideoController(String videoPath) {
    video.value = VideoControllerModel(videoPath: videoPath);
  }

  @override
  void onInit() {
    super.onInit();
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(video.value.videoPath))
      ..initialize().then((_) {
        video.update((v) => v?.frameRate =
            videoPlayerController.value.duration.inMilliseconds / videoPlayerController.value.duration.inSeconds);
        video.update((v) => v?.videoDuration = videoPlayerController.value.duration);
        videoPlayerController.addListener(() {
          video.update((v) => v?.videoPosition = videoPlayerController.value.position.inMilliseconds /
              videoPlayerController.value.duration.inMilliseconds);
        });
      });
  }

  void setFrameRate(double d) {
    // video.value.frameRate = d;
    video.update((v) => v?.frameRate = d);
  }

  void onChangeSliderPosition(double d) {
    final newPosition = Duration(milliseconds: (video.value.videoDuration!.inMilliseconds * d).toInt());
    videoPlayerController.seekTo(newPosition);
    video.update((v) => v?.videoPosition = d);
  }

  void seekFrame(int direction) async {
    if (!videoPlayerController.value.isInitialized) return;
    Duration currentPosition = await videoPlayerController.position ?? Duration.zero;
    int frameStep = (1000 / video.value.frameRate!).round();
    Duration newPosition = currentPosition + Duration(milliseconds: frameStep * direction);
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > videoPlayerController.value.duration) {
      newPosition = videoPlayerController.value.duration;
    }
    videoPlayerController.seekTo(newPosition);
  }

  //Toggle video controls, if they are visible for 3 seconds, hide them
  void toggleShowOptions() async {
    showVideoControls.value = !showVideoControls.value;
    if (showVideoControls.value) {
      await Future.delayed(Duration(seconds: 3));
      showVideoControls.value = false;
    }
  }

  void togglePlay() {
    videoPlayerController.value.isPlaying ? videoPlayerController.pause() : videoPlayerController.play();
    video.value.isPlaying = !video.value.isPlaying!;
  }

  @override
  void onClose() {
    videoPlayerController.dispose();
    super.onClose();
  }
}
