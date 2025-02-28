import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_collection/app/components/index.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/proviers/index.dart';
import 'package:video_collection/app/screens/index.dart';
import 'package:video_collection/app/widgets/index.dart';

class AllVideoScreen extends StatelessWidget {
  String title;
  List<VideoModel> list;
  AllVideoScreen({super.key, required this.title, required this.list});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      contentPadding: 2,
      appBar: AppBar(
        title: Text(title),
      ),
      body: VideoListView(
        list: list,
        onClick: (video) {
          context.read<VideoProvider>().setCurrentVideo(video);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoContentScreen(),
            ),
          );
        },
      ),
    );
  }
}
