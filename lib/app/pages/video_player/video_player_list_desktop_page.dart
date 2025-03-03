import 'dart:io';

import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_collection/app/components/index.dart';
import 'package:video_collection/app/extensions/index.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/services/index.dart';
import 'package:video_collection/app/utils/app_util.dart';
import 'package:video_collection/app/widgets/core/index.dart';

class VideoPlayerListDesktopPage extends StatefulWidget {
  List<VideoFileModel> list;
  bool isAutoPlay;
  VideoPlayerListDesktopPage({
    super.key,
    required this.list,
    this.isAutoPlay = false,
  });

  @override
  State<VideoPlayerListDesktopPage> createState() =>
      _VideoPlayerListDesktopPageState();
}

class _VideoPlayerListDesktopPageState
    extends State<VideoPlayerListDesktopPage> {
  @override
  void initState() {
    listScrollController.addListener(_onScroll);
    super.initState();
    init();
  }

  @override
  void dispose() {
    listScrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final width = MediaQuery.of(context).size.width;
    //scroll down
    if (listScrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (width < 550) {
        setState(() {
          isPlayerSmallSize = true;
        });
      }
    }
    //scroll up
    if (listScrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (width < 550) {
        setState(() {
          isPlayerSmallSize = false;
        });
      }
    }
  }

  late final Player player = Player();
  late final VideoController _controller = VideoController(player);
  final ScrollController listScrollController = ScrollController();

  int allSeconds = 0;
  int progressSeconds = 0;
  int currentVideoIndex = 0;
  bool isPlayerSmallSize = false;
  double? playerHeight;
  double playerRatio = 16 / 9;
  double mobileVideoPlayerMinHeight = 200;

  void init() async {
    try {
      if (widget.list.isNotEmpty) {
        await player.open(Media(_getFilePath()));
        //listen player loaded or not
        //delay
        await Future.delayed(Duration(milliseconds: 600));

        //listen player loaded or not
        if (player.state.duration > Duration.zero) {
          final seconds = await VideoPlayerConfigService.instance
              .getConfig(videoPath: widget.list[currentVideoIndex].path);
          if (seconds > 0) {
            player.seek(Duration(seconds: seconds));
          }
          //file ရှိနေတယ်
          // if (!mounted) return;
          // final screenWidth = MediaQuery.of(context).size.width;
          // final ratio = player.state.videoParams.aspect ?? 16 / 9;
          // final calculatedHeight = screenWidth / ratio;
          // setState(() {
          //   playerRatio = ratio;
          //   playerHeight = calculatedHeight;
          // });
        } else {
          playerHeight = null;
        }
      }
    } catch (e) {
      if (!mounted) return;
      showDialogMessage(context, e.toString());
    }
  }

  String _getFilePath() {
    return widget.list[currentVideoIndex].path;
  }

  void _videoItemClicked(int index) async {
    if (currentVideoIndex == index) return;
    await VideoPlayerConfigService.instance.setConfig(
      videoPath: widget.list[currentVideoIndex].path,
      seconds: player.state.position.inSeconds,
    );

    setState(() {
      currentVideoIndex = index;
    });
    init();
  }

  Widget _getListWidget(double width) {
    return ListView.builder(
      controller: listScrollController,
      itemCount: widget.list.length,
      itemBuilder: (context, index) {
        final videoFile = widget.list[index];
        return GestureDetector(
          onTap: () => _videoItemClicked(index),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Card(
              color: index == currentVideoIndex
                  ? const Color.fromARGB(255, 5, 73, 66)
                  : null,
              child: Row(
                spacing: 5,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: _getListCoverSize(width),
                      height: _getListCoverSize(width),
                      child: MyImageFile(
                        path: videoFile.coverPath,
                        borderRadius: 6,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          videoFile.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                        Text('Type: ${videoFile.type.name.toCaptalize()}'),
                        Text(getParseFileSize(videoFile.size.toDouble())),
                        Text(getParseDate(videoFile.date)),
                        VideoFileBookmarkButton(
                          videoFile: videoFile,
                          coverPath: videoFile.coverPath,
                          filePath: _getFilePath(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _getVideoListWidth(double width) {
    if (width < 650) {
      return 230;
    }
    if (width < 550) {
      return 280;
    }
    if (width < 1000) {
      return 380;
    }
    return 400;
  }

  double _getListCoverSize(double width) {
    if (width < 350) {
      return 100;
    }
    if (width < 550) {
      return 120;
    }
    if (width < 1400) {
      return 150;
    }
    return 80;
  }

  Widget _getDescWidget() {
    return FutureBuilder(
      future: VideoFileService.instance
          .getDesc(videoFile: widget.list[currentVideoIndex]),
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
    );
  }

  Widget _getDesktop(double width) {
    return Row(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          // width: 400,
          child: SingleChildScrollView(
            child: Column(
              spacing: 10,
              children: [
                AnimatedSize(
                  duration: Duration(milliseconds: 200),
                  child: AspectRatio(
                    aspectRatio: playerRatio,
                    child: Video(
                      controller: _controller,
                      // onEnterFullscreen: () async {
                      //   final height = player.state.height ?? 0;
                      //   final width = player.state.width ?? 0;
                      //   if (height > width) {
                      //   } else {
                      //     await defaultEnterNativeFullscreen();
                      //   }
                      // },
                    ),
                  ),
                ),
                //desc
                _getDescWidget(),
              ],
            ),
          ),
        ),
        //list
        SizedBox(
          width: _getVideoListWidth(width),
          child: _getListWidget(width),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        await VideoPlayerConfigService.instance.setConfig(
          videoPath: widget.list[currentVideoIndex].path,
          seconds: player.state.position.inSeconds,
        );
        await player.playOrPause();
        await player.dispose();
      },
      child: MyScaffold(
        contentPadding: 0,
        appBar: Platform.isLinux ? AppBar() : null,
        body: _getDesktop(width),
      ),
    );
  }
}
