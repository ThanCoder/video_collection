import 'dart:io';

import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:than_pkg/enums/screen_orientation_types.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:video_collection/app/components/core/index.dart';
import 'package:video_collection/app/services/index.dart';
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
  double? playerHeight;
  double playerRatio = 16 / 9;
  double mobileVideoPlayerMinHeight = 200;

  void init() async {
    try {
      await player.open(Media(widget.video.path));
      //delay
      await Future.delayed(Duration(milliseconds: 600));

      //listen player loaded or not
      if (player.state.duration > Duration.zero) {
        //file ရှိနေတယ်
        if (!mounted) return;
        final screenWidth = MediaQuery.of(context).size.width;
        final ratio = player.state.videoParams.aspect ?? 16 / 9;
        final calculatedHeight = screenWidth / ratio;
        setState(() {
          playerRatio = ratio;
          playerHeight = calculatedHeight;
        });
      } else {
        playerHeight = null;
      }
    } catch (e) {
      if (!mounted) return;
      showDialogMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await player.playOrPause();
          await player.dispose();
        }
      },
      child: MyScaffold(
        contentPadding: 0,
        appBar: AppBar(
          title: Text('Video Player'),
        ),
        body: SingleChildScrollView(
          child: Column(
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
                      onEnterFullscreen: () async {
                        final height = player.state.height ?? 0;
                        final width = player.state.width ?? 0;
                        if (height > width) {
                          if (Platform.isAndroid) {
                            await ThanPkg.platform.requestScreenOrientation(
                              type: ScreenOrientationTypes.Portrait,
                            );
                            ThanPkg.android.app
                                .toggleKeepScreenOn(isKeep: true);
                          }
                        } else {
                          await defaultEnterNativeFullscreen();
                        }
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  spacing: 10,
                  children: [
                    Text(widget.video.title),
                    FutureBuilder(
                      future: VideoFileService.instance
                          .getDesc(videoFile: widget.video),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ExpandableText(
                            snapshot.data!,
                            expandText: 'Read More',
                            collapseText: 'Read Less',
                            collapseOnTextTap: true,
                            maxLines: 3,
                            linkColor: Colors.blue,
                            animation: true,
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                //desc
              ),
            ],
          ),
        ),
      ),
    );
  }
}
