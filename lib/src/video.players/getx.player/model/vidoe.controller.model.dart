class VideoControllerModel {
  String videoPath; 
  bool? isPlaying;
  double? frameRate;
  double? videoPosition;
  Duration? videoDuration;
  bool? intaractable;
  VideoControllerModel({
    required this.videoPath, 
    this.isPlaying = true,
    this.frameRate = 30.0,
    this.videoPosition = 0.0,
    this.videoDuration = Duration.zero,
    this.intaractable = false,
  });
}
