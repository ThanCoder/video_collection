import 'package:flutter/material.dart';
import 'package:video_collection/app/enums/video_file_info_types.dart';
import 'package:video_collection/app/extensions/string_extension.dart';

class VideoFileInfoTypesDialog extends StatefulWidget {
  VideoFileInfoTypes type;
  void Function(VideoFileInfoTypes type) onChoosed;
  VideoFileInfoTypesDialog({
    super.key,
    required this.type,
    required this.onChoosed,
  });

  @override
  State<VideoFileInfoTypesDialog> createState() =>
      _VideoFileInfoTypesDialogState();
}

class _VideoFileInfoTypesDialogState extends State<VideoFileInfoTypesDialog> {
  List<DropdownMenuItem<VideoFileInfoTypes>> _getList() {
    final values = VideoFileInfoTypes.values;
    return values
        .map(
          (v) => DropdownMenuItem<VideoFileInfoTypes>(
            value: v,
            child: Text(
              v.name.toCaptalize(),
            ),
          ),
        )
        .toList();
  }

  VideoFileInfoTypes type = VideoFileInfoTypes.info;

  @override
  void initState() {
    type = widget.type;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Choose File Info Type'),
      content: SingleChildScrollView(
        child: Row(
          spacing: 10,
          children: [
            Text('File Info Type'),
            DropdownButton<VideoFileInfoTypes>(
              borderRadius: BorderRadius.circular(4),
              items: _getList(),
              value: type,
              onChanged: (value) {
                setState(() {
                  type = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onChoosed(type);
          },
          child: Text('Update'),
        ),
      ],
    );
  }
}
