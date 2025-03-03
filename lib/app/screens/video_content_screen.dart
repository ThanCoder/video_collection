import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_collection/app/components/index.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/pages/index.dart';
import 'package:video_collection/app/proviers/index.dart';
import 'package:video_collection/app/utils/app_util.dart';
import 'package:video_collection/app/widgets/index.dart';

class VideoContentScreen extends StatefulWidget {
  const VideoContentScreen({super.key});

  @override
  State<VideoContentScreen> createState() => _VideoContentScreenState();
}

class _VideoContentScreenState extends State<VideoContentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    final video = context.read<VideoProvider>().getCurrentVideo;
    context.read<VideoFileProvider>().initList(videoId: video!.id);
  }

  void _goPlayerScreen(List<VideoFileModel> videoFileList) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerListDesktopPage(
            list: videoFileList,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerListMobilePage(
            list: videoFileList,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //video
    final video = context.watch<VideoProvider>().getCurrentVideo;
    //video file
    final isLoading = context.watch<VideoFileProvider>().isLoading;
    final videoFileList = context.watch<VideoFileProvider>().getList;

    return MyScaffold(
      appBar: AppBar(
        title: Text(video!.title),
        actions: [
          VideoContextMenuButton(
            onDone: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: isLoading
          ? TLoader()
          : SingleChildScrollView(
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: MyImageFile(
                          path: video.coverPath,
                          borderRadius: 5,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10,
                          children: [
                            Text(video.title),
                            Text(video.genres),
                            Text(video.type.name),
                            Text(getParseDate(video.date)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    runAlignment: WrapAlignment.start,
                    children: [
                      videoFileList.isEmpty
                          ? SizedBox.shrink()
                          : ElevatedButton(
                              onPressed: () => _goPlayerScreen(videoFileList),
                              child: Text('Start Watch'),
                            ),
                    ],
                  ),
                  videoFileList.isEmpty ? SizedBox.shrink() : const Divider(),
                  VideoContentCoverListView(videoId: video.id),
                  //desc
                  Text(
                    video.desc,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
