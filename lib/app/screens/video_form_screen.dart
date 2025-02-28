import 'package:flutter/material.dart';
import 'package:video_collection/app/pages/index.dart';

class VideoFormScreen extends StatelessWidget {
  const VideoFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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
    );
  }
}
