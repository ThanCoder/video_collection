import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_collection/app/proviers/index.dart';
import 'package:video_collection/app/services/video_services.dart';
import 'package:video_collection/app/widgets/index.dart';

class VideoContentCoverFormPage extends StatefulWidget {
  const VideoContentCoverFormPage({super.key});

  @override
  State<VideoContentCoverFormPage> createState() =>
      _VideoContentCoverFormPageState();
}

class _VideoContentCoverFormPageState extends State<VideoContentCoverFormPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  void init() async {
    final video = context.read<VideoProvider>().getCurrentVideo;
    if (video == null) return;
    await context.read<ContentFileProvider>().initList(videoId: video.id);
  }

  String _getCoverPath(String name) {
    final video = context.read<VideoProvider>().getCurrentVideo;
    if (video == null) return '';
    return '${VideoServices.instance.getSourcePath(video.id)}/$name';
  }

  @override
  Widget build(BuildContext context) {
    final videoId = context.watch<VideoProvider>().getCurrentVideo!.id;
    final provider = context.watch<ContentFileProvider>();
    final isLoading = provider.isLoading;
    final contentFileList = provider.getList;

    return MyScaffold(
      body: isLoading
          ? Center(child: TLoader())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150,
                mainAxisExtent: 150,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              itemCount: contentFileList.length,
              itemBuilder: (context, index) {
                final name = contentFileList[index];
                return GestureDetector(
                  onLongPress: () {
                    context.read<ContentFileProvider>().deleteWithConfirm(
                        context,
                        videoId: videoId,
                        name: name);
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: MyImageFile(
                      path: _getCoverPath(name),
                      borderRadius: 5,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<ContentFileProvider>().addFromPath(
                videoId: context.read<VideoProvider>().getCurrentVideo!.id,
              );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
