import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_collection/app/extensions/index.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/utils/index.dart';
import 'package:video_collection/app/widgets/core/index.dart';

class VideoFileSeeAllListView extends StatelessWidget {
  String title;
  List<VideoFileModel> list;
  void Function(VideoFileModel video) onClick;
  void Function() onSeeAll;
  VideoFileSeeAllListView({
    super.key,
    this.title = 'Untitled',
    required this.list,
    required this.onClick,
    required this.onSeeAll,
  });

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
    if (list.isEmpty) {
      return SizedBox.shrink();
    }
    return Column(
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
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: MyImageFile(
                        path: _getCoverPath(video),
                        borderRadius: 5,
                      ),
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
