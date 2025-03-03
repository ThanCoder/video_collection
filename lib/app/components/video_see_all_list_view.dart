import 'package:flutter/material.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/widgets/core/index.dart';

class VideoSeeAllListView extends StatelessWidget {
  String title;
  List<VideoModel> list;
  void Function(VideoModel video) onClick;
  void Function() onSeeAll;
  VideoSeeAllListView({
    super.key,
    this.title = 'Untitled',
    required this.list,
    required this.onClick,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            TextButton(onPressed: onSeeAll, child: Text('SeeAll')),
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 5,
            children: List.generate(
              list.length,
              (index) {
                final video = list[index];
                return GestureDetector(
                  onTap: () => onClick(video),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: MyImageFile(
                            path: video.coverPath,
                            borderRadius: 5,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(158, 58, 58, 58),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(5),
                                  bottomRight: Radius.circular(5),
                                )),
                            child: Text(
                              video.title,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
