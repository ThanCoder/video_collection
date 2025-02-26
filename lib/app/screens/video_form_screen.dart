import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_collection/app/pages/index.dart';
import 'package:video_collection/app/proviers/index.dart';
import 'package:video_collection/app/widgets/index.dart';

class VideoFormScreen extends StatefulWidget {
  const VideoFormScreen({super.key});

  @override
  State<VideoFormScreen> createState() => _VideoFormScreenState();
}

class _VideoFormScreenState extends State<VideoFormScreen> {
  void _save() async {
    final provider = context.read<VideoProvider>();
    final video = provider.getCurrentVideo;
    if (video == null) return;
    await provider.update(video: video);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final video = context.watch<VideoProvider>().getCurrentVideo;
    return MyScaffold(
      contentPadding: 0,
      appBar: AppBar(
        title: Text('Video Form `${video!.title}`'),
        actions: [
          IconButton(
            // ignore: unnecessary_null_comparison
            onPressed: video != null ? _save : null,
            icon: Icon(Icons.save_as_outlined),
          ),
          IconButton(
            color: Colors.red,
            onPressed: () {
              context.read<VideoProvider>().deleteWithConfirm(
                context,
                video: video,
                onDoned: () {
                  Navigator.pop(context);
                },
              );
            },
            icon: Icon(Icons.delete_forever),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: TabBarView(
            children: [
              const VideoHomeFormPage(),
              const VideoFileFormPage(),
              const VideoContentCoverFormPage(),
            ],
          ),
          bottomNavigationBar: TabBar(
            tabs: [
              Tab(text: 'Form'),
              Tab(text: 'Video File'),
              Tab(text: 'Content Cover'),
            ],
          ),
        ),
      ),
    );
  }
}
