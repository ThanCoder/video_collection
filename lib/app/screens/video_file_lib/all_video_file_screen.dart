import 'package:flutter/material.dart';
import 'package:video_collection/app/components/video_file_list_view.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/screens/index.dart';
import 'package:video_collection/app/widgets/index.dart';

class AllVideoFileScreen extends StatelessWidget {
  String title;
  List<VideoFileModel> list;
  AllVideoFileScreen({super.key, required this.title, required this.list});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      contentPadding: 2,
      appBar: AppBar(
        title: Text(title),
      ),
      body: VideoFileListView(
        list: list,
        onClick: (video) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(video: video),
            ),
          );
        },
      ),
    );
  }
}
