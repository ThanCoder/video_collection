import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:video_collection/app/components/core/index.dart';
import 'package:video_collection/app/widgets/core/index.dart';

import '../models/index.dart';

class VideoPlayerScreen extends StatefulWidget {
  VideoFileModel video;
  bool isAutoPlay;
  VideoPlayerScreen({
    super.key,
    required this.video,
    this.isAutoPlay = false,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      ThanPkg.platform.toggleFullScreen(isFullScreen: true);
    }
    init();
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      ThanPkg.platform.toggleFullScreen(isFullScreen: false);
    }
    super.dispose();
  }

  late final Player player = Player();
  late final VideoController _controller = VideoController(player);

  int allSeconds = 0;
  int progressSeconds = 0;

  void init() {
    try {
      player.open(Media(widget.video.path));
    } catch (e) {
      showDialogMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await player.playOrPause();
        await player.dispose();
        return true;
      },
      child: MyScaffold(
        contentPadding: 0,
        appBar: AppBar(
          title: Text('Video Player'),
        ),
        body: Column(
          spacing: 10,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 1100,
                ),
                child: AspectRatio(
                  aspectRatio: player.state.videoParams.aspect ?? 16 / 9,
                  child: Video(
                    controller: _controller,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.video.title),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
