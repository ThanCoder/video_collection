import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:video_collection/app/components/core/index.dart';
import 'package:video_collection/app/extensions/index.dart';
import 'package:video_collection/app/utils/app_util.dart';
import 'package:video_collection/app/utils/path_util.dart';
import 'package:video_collection/app/widgets/core/index.dart';

import '../models/index.dart';

class VideoPlayerWithListScreen extends StatefulWidget {
  List<VideoFileModel> list;
  bool isAutoPlay;
  VideoPlayerWithListScreen({
    super.key,
    required this.list,
    this.isAutoPlay = false,
  });

  @override
  State<VideoPlayerWithListScreen> createState() =>
      _videoPlayerWithListScreenState();
}

class _videoPlayerWithListScreenState extends State<VideoPlayerWithListScreen> {
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
  int currentVideoIndex = 0;

  void init() {
    try {
      if (widget.list.isNotEmpty) {
        player.open(Media(widget.list[currentVideoIndex].path));
      }
    } catch (e) {
      showDialogMessage(context, e.toString());
    }
  }

  String _getTitle() {
    if (widget.list.isNotEmpty) {
      return widget.list[currentVideoIndex].title;
    }
    return '';
  }

  String _getCoverPath(VideoFileModel file) {
    final coverFile =
        File('${getCachePath()}/${file.title.getName(withExt: false)}.png');
    if (coverFile.existsSync()) {
      return coverFile.path;
    }
    return '${getCachePath()}/${file.id}.png';
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
          title: Text(_getTitle()),
        ),
        body: Column(
          children: [
            widget.list.isEmpty
                ? Center(child: Text('Video List မရှိပါ'))
                : SizedBox(
                    width: double.infinity,
                    child: AspectRatio(
                      aspectRatio: player.state.videoParams.aspect ?? 16 / 9,
                      child: Video(
                        controller: _controller,
                      ),
                    ),
                  ),
            //list
            const Divider(),
            Expanded(
              child: ListView.builder(
                // shrinkWrap: true,
                itemCount: widget.list.length,
                itemBuilder: (context, index) {
                  final _video = widget.list[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentVideoIndex = index;
                      });
                      init();
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Card(
                        color: index == currentVideoIndex ? Colors.teal : null,
                        child: Row(
                          spacing: 5,
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: MyImageFile(
                                path: _getCoverPath(_video),
                                borderRadius: 5,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                spacing: 10,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_video.title),
                                  Text(
                                      getParseFileSize(_video.size.toDouble())),
                                  Text(getParseDate(_video.date)),
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
            ),
          ],
        ),
      ),
    );
  }
}
