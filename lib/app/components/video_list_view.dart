import 'package:flutter/material.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/notifiers/app_notifier.dart';
import 'package:video_collection/app/widgets/index.dart';

class VideoListView extends StatelessWidget {
  List<VideoModel> list;
  void Function(VideoModel video) onClick;
  VideoListView({
    super.key,
    required this.list,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 180,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
      itemBuilder: (context, index) {
        final video = list[index];
        return VideoListItem(video: video, onClick: onClick);
      },
      itemCount: list.length,
    );
  }
}

class VideoListItem extends StatelessWidget {
  VideoModel video;
  void Function(VideoModel video) onClick;
  VideoListItem({
    super.key,
    required this.video,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClick(video),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          children: [
            SizedBox(
              width: double.maxFinite,
              height: double.maxFinite,
              child: MyImageFile(
                path: video.coverPath,
                borderRadius: 5,
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: Container(
                color: isDarkThemeNotifier.value
                    ? Colors.black
                    : const Color.fromARGB(220, 204, 204, 204),
                child: Text(
                  video.title,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
