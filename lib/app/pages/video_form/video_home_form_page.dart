import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_collection/app/components/index.dart';
import 'package:video_collection/app/proviers/video_provider.dart';
import 'package:video_collection/app/services/video_services.dart';
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

  void _save() async {
    final provider = context.read<VideoProvider>();
    final video = provider.getCurrentVideo;
    if (video == null) return;
    await provider.update(video: video);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentVideo = context.read<VideoProvider>().getCurrentVideo;
    final video = context.watch<VideoProvider>().getCurrentVideo;
    return MyScaffold(
      appBar: AppBar(
        title: Text('Video Form `${video!.title}`'),
        actions: [
          IconButton(
            // ignore: unnecessary_null_comparison
            onPressed: video != null ? _save : null,
            icon: Icon(Icons.save_as_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              //cover
              CoverComponents(
                  coverPath:
                      '${VideoServices.instance.getSourcePath(currentVideo!.id)}/cover.png'),
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
      ),
    );
  }
}
