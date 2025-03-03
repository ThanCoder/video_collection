import 'package:flutter/material.dart';
import 'package:video_collection/app/pages/index.dart';

import '../models/index.dart';

class VideoPlayerWithListScreen extends StatelessWidget {
  List<VideoFileModel> list;
  bool isAutoPlay;
  VideoPlayerWithListScreen({
    super.key,
    required this.list,
    this.isAutoPlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return VideoPlayerListDesktopPage(list: list);
    } else {
      return VideoPlayerListMobilePage(list: list);
    }
  }
}
