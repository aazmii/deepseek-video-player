import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../video.player/video.player.screen.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: ElevatedButton(
          onPressed: () => _pickVideoAndShowVideoPlayer(context),
          child: Text('Pick Video'),
        ),
      ),
    );
  }

  _pickVideoAndShowVideoPlayer(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );
    if (result != null && context.mounted) {
      String videoPath = result.files.single.path!;
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return VideoPlayerScreen(videoPath: videoPath);
      }));
      // final file = VideoPlayerController.file(File(videoPath));
      // file.path;
    }
  }
}
