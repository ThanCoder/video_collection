import 'package:flutter/material.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/services/index.dart';
import 'package:video_collection/app/widgets/index.dart';

class VideoFileDescEditDialog extends StatefulWidget {
  VideoFileModel videoFile;
  VideoFileDescEditDialog({super.key, required this.videoFile});

  @override
  State<VideoFileDescEditDialog> createState() =>
      _VideoFileDescEditDialogState();
}

class _VideoFileDescEditDialogState extends State<VideoFileDescEditDialog> {
  final TextEditingController descController = TextEditingController();
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    descController.text =
        await VideoFileService.instance.getDesc(videoFile: widget.videoFile);
  }

  @override
  void dispose() {
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.videoFile.title}'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TTextField(
              controller: descController,
              label: Text('Description'),
              maxLines: 5,
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
          onPressed: () async {
            Navigator.pop(context);
            await VideoFileService.instance.setDesc(
              videoFile: widget.videoFile,
              text: descController.text,
            );
          },
          child: Text('Update'),
        ),
      ],
    );
  }
}
