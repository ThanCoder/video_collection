import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_collection/app/components/index.dart';
import 'package:video_collection/app/proviers/video_provider.dart';
import 'package:video_collection/app/widgets/index.dart';

class VideoHomeFormPage extends StatefulWidget {
  const VideoHomeFormPage({super.key});

  @override
  State<VideoHomeFormPage> createState() => _VideoHomeFormPageState();
}

class _VideoHomeFormPageState extends State<VideoHomeFormPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  void init() {
    final video = context.read<VideoProvider>().getCurrentVideo;
    if (video == null) return;
    titleController.text = video.title;
    descController.text = video.desc;
  }

  @override
  Widget build(BuildContext context) {
    final currentVideo = context.read<VideoProvider>().getCurrentVideo;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            //cover
            CoverComponents(coverPath: currentVideo!.coverPath),
            //title
            TTextField(
              label: Text('Title'),
              controller: titleController,
              onChanged: (value) {
                currentVideo.title = value;
              },
            ),
            //type
            Row(
              spacing: 10,
              children: [
                Text('Video Type'),
                VideoTypeChooserComponent(
                  type: currentVideo.type,
                  onChanged: (type) {
                    currentVideo.type = type;
                  },
                ),
              ],
            ),
            //desc
            TTextField(
              label: Text('Description'),
              controller: descController,
              maxLines: 5,
              onChanged: (value) {
                currentVideo.desc = value;
              },
            ),
          ],
        ),
      ),
    );
  }
}
