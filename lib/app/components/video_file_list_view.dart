import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_collection/app/extensions/string_extension.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/utils/index.dart';
import 'package:video_collection/app/widgets/index.dart';

class VideoFileListView extends StatelessWidget {
  List<VideoFileModel> list;
  void Function(VideoFileModel videoFile) onClick;
  void Function(VideoFileModel videoFile)? onLongClick;
  VideoFileListView({
    super.key,
    required this.list,
    required this.onClick,
    this.onLongClick,
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
    return ListView.builder(
      itemBuilder: (context, index) {
        final file = list[index];

        return GestureDetector(
          onTap: () => onClick(file),
          onLongPress: () {
            if (onLongClick != null) {
              onLongClick!(file);
            }
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Card(
              child: Row(
                spacing: 10,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: MyImageFile(
                      path: _getCoverPath(file),
                      borderRadius: 5,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(file.title),
                        Text(getParseFileSize(file.size.toDouble())),
                        Text(getParseDate(file.date)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      // separatorBuilder: (context, index) => const Divider(),
      itemCount: list.length,
    );
  }
}
