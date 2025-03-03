import 'dart:io';

import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:than_pkg/enums/screen_orientation_types.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:video_collection/app/components/index.dart';
import 'package:video_collection/app/extensions/index.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/services/index.dart';
import 'package:video_collection/app/utils/app_util.dart';
import 'package:video_collection/app/widgets/core/index.dart';

class VideoPlayerListMobilePage extends StatefulWidget {
  List<VideoFileModel> list;
  bool isAutoPlay;
  VideoPlayerListMobilePage({
    super.key,
    required this.list,
    this.isAutoPlay = false,
  });

  @override
  State<VideoPlayerListMobilePage> createState() =>
      _VideoPlayerListMobilePageState();
}

class _VideoPlayerListMobilePageState extends State<VideoPlayerListMobilePage> {
  late final Player player = Player();
  late final VideoController _controller = VideoController(player);
  final ScrollController listScrollController = ScrollController();
  // late AnimationController animationController;
  // late Animation<double> animationHeight;

  int allSeconds = 0;
  int progressSeconds = 0;
  int currentVideoIndex = 0;
  bool isPlayerSmallSize = false;
  double? playerHeight;
  double playerRatio = 16 / 9;
  double videoPlayerMinHeight = 200;

  @override
  void initState() {
    super.initState();
    listScrollController.addListener(_onScroll);

    init();
  }

  @override
  void dispose() {
    // animationController.dispose();
    listScrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    //scroll down
    if (listScrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      setState(() {
        videoPlayerMinHeight = 200;
      });
    }
    //scroll up
    if (listScrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (playerHeight != null) {
        double halfSize = MediaQuery.of(context).size.height * 0.6;
        double height = playerHeight!;
        if (height < 200) {
          height = 200;
        } else if (height > halfSize) {
          height = halfSize;
        }
        // print('height $height - half: $halfSize');
        setState(() {
          videoPlayerMinHeight = height;
        });
      }
    }
  }

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

  Widget _getVideoWidet() {
    if (widget.list.isEmpty) {
      return Center(child: Text('Video List မရှိပါ'));
    }
    return AnimatedSize(
      duration: Duration(milliseconds: 400),
      child: SizedBox(
        height: playerHeight,
        width: double.infinity,
        child: AspectRatio(
          aspectRatio: playerRatio,
          child: Video(
            controller: _controller,
            // controls: CupertinoVideoControls,5
            onEnterFullscreen: () async {
              final height = player.state.height ?? 0;
              final width = player.state.width ?? 0;
              if (height > width) {
                if (Platform.isAndroid) {
                  await ThanPkg.platform.requestScreenOrientation(
                    type: ScreenOrientationTypes.Portrait,
                  );
                  ThanPkg.platform.toggleFullScreen(isFullScreen: true);
                }
              } else {
                await defaultEnterNativeFullscreen();
              }
            },
            onExitFullscreen: () async {
              await defaultExitNativeFullscreen();
            },
          ),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
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
        body: CustomScrollView(
          controller: listScrollController,
          slivers: [
            //video
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight:
                  playerHeight, // Height of the app bar when expanded
              floating: false,
              collapsedHeight: videoPlayerMinHeight,
              pinned: true, // Makes the app bar sticky at the top
              flexibleSpace: SafeArea(child: _getVideoWidet()),
            ),
            //desc
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _getDescWidget(),
              ),
            ),
            //list
            SliverList.builder(
              itemCount: widget.list.length,
              itemBuilder: (context, index) {
                final videoFile = widget.list[index];
                return GestureDetector(
                  onTap: () => _videoItemClicked(index),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Card(
                      child: Row(
                        spacing: 5,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: index == currentVideoIndex
                                    ? const Color.fromARGB(255, 13, 73, 65)
                                    : Colors.transparent,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 100,
                              height: 100,
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
                                Text(
                                    'Type: ${videoFile.type.name.toCaptalize()}'),
                                Text(getParseFileSize(
                                    videoFile.size.toDouble())),
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
            ),
          ],
        ),
      ),
    );
  }
}
