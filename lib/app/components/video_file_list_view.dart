import 'package:flutter/material.dart';
import 'package:video_collection/app/components/video_file_bookmark_button.dart';
import 'package:video_collection/app/extensions/string_extension.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/utils/index.dart';
import 'package:video_collection/app/widgets/index.dart';

class VideoFileListView extends StatelessWidget {
  List<VideoFileModel> list;
  void Function(VideoFileModel videoFile) onClick;
  void Function(VideoFileModel videoFile)? onLongClick;
  void Function(VideoFileModel videoFile)? onMenuClick;
  VideoFileListView(
      {super.key,
      required this.list,
      required this.onClick,
      this.onLongClick,
      this.onMenuClick});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final vf = list[index];
        // print('type: ${vf.type.name} - ${vf.coverPath}');
        // print(vf.path);
        return GestureDetector(
          onTap: () => onClick(vf),
          onLongPress: () {
            if (onLongClick != null) {
              onLongClick!(vf);
            }
          },
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
                    ),
                  ),
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
      },
      // separatorBuilder: (context, index) => const Divider(),
      itemCount: list.length,
    );
  }
}
