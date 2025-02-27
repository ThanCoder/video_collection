import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:video_collection/app/constants.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/services/index.dart';
import 'package:video_collection/app/widgets/index.dart';

class VideoFileBookmarkButton extends StatefulWidget {
  VideoFileModel videoFile;
  String coverPath;
  String filePath;
  VideoFileBookmarkButton({
    super.key,
    required this.videoFile,
    required this.coverPath,
    required this.filePath,
  });

  @override
  State<VideoFileBookmarkButton> createState() =>
      _VideoFileBookmarkButtonState();
}

class _VideoFileBookmarkButtonState extends State<VideoFileBookmarkButton> {
  bool isExistsBookmark = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  void init() async {
    try {
      final res = await VideoFileBookmarkService.instance
          .isExists(title: widget.videoFile.title);
      if (!mounted) return;
      setState(() {
        isExistsBookmark = res;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return TLoader(
        size: 30,
      );
    }
    return IconButton(
      onPressed: () async {
        setState(() {
          isLoading = true;
        });
        final bookmark = VideoFileBookmarkModel(
          id: Uuid().v4(),
          videoId: widget.videoFile.videoId,
          videoFileId: widget.videoFile.id,
          coverPath: widget.coverPath,
          filePath: widget.filePath,
          title: widget.videoFile.title,
          size: widget.videoFile.size,
          date: DateTime.now().millisecondsSinceEpoch,
        );
        await VideoFileBookmarkService.instance.toggle(bookmark: bookmark);
        if (!mounted) return;
        setState(() {
          isExistsBookmark = !isExistsBookmark;
          isLoading = false;
        });
      },
      color: isExistsBookmark
          ? dangerColor
          : const Color.fromARGB(255, 16, 98, 165),
      icon: Icon(isExistsBookmark
          ? Icons.bookmark_remove_rounded
          : Icons.bookmark_add_rounded),
    );
  }
}
