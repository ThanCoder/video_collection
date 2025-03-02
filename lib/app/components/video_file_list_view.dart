import 'package:flutter/material.dart';
import 'package:video_collection/app/components/index.dart';
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final vf = list[index];
        return VideoFileListItem(
          vf: vf,
          onClick: onClick,
          onLongClick: (videoFile) {
            if (onLongClick != null) {
              onLongClick!(vf);
            }
          },
        );
      },
      // separatorBuilder: (context, index) => const Divider(),
      itemCount: list.length,
    );
  }
}

class VideoFileListItem extends StatelessWidget {
  VideoFileModel vf;
  void Function(VideoFileModel videoFile) onClick;
  void Function(VideoFileModel videoFile) onLongClick;
  VideoFileListItem({
    super.key,
    required this.vf,
    required this.onClick,
    required this.onLongClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClick(vf),
      onLongPress: () => onLongClick(vf),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          color: vf.isSelected ? Colors.blue[900] : null,
          child: Row(
            spacing: 10,
            children: [
              SizedBox(
                  width: 150,
                  height: 150,
                  child: MyImageFile(
                    path: vf.coverPath,
                    borderRadius: 5,
                  )),
              Expanded(
                child: Column(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vf.title),
                    Text('Type: ${vf.type.name.toCaptalize()}'),
                    Text(getParseFileSize(vf.size.toDouble())),
                    Text(getParseDate(vf.date)),
                    VideoFileBookmarkButton(
                      videoFile: vf,
                      coverPath: vf.coverPath,
                      filePath: vf.path,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
