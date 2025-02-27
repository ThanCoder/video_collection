import 'package:flutter/material.dart';
import 'package:video_collection/app/components/index.dart';
import 'package:video_collection/app/enums/video_types.dart';

class VideoTypesDialog extends StatefulWidget {
  void Function(VideoTypes type) onChoosed;
  VideoTypesDialog({
    super.key,
    required this.onChoosed,
  });

  @override
  State<VideoTypesDialog> createState() => _VideoTypesDialogState();
}

class _VideoTypesDialogState extends State<VideoTypesDialog> {
  VideoTypes vType = VideoTypes.movie;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          spacing: 10,
          children: [
            Text('Choose Video Type'),
            VideoTypeChooserComponent(
              type: VideoTypes.movie,
              onChanged: (type) {
                vType = type;
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
            widget.onChoosed(vType);
          },
          child: Text('Choose'),
        ),
      ],
    );
  }
}
