import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_collection/app/components/index.dart';
import 'package:video_collection/app/components/video_file_list_view.dart';
import 'package:video_collection/app/constants.dart';
import 'package:video_collection/app/dialogs/index.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/notifiers/app_notifier.dart';
import 'package:video_collection/app/proviers/index.dart';
import 'package:video_collection/app/screens/index.dart';
import 'package:video_collection/app/services/core/app_services.dart';
import 'package:video_collection/app/services/video_services.dart';
import 'package:video_collection/app/widgets/index.dart';

class VideoFileFormPage extends StatefulWidget {
  const VideoFileFormPage({super.key});

  @override
  State<VideoFileFormPage> createState() => _VideoFileFormPageState();
}

class _VideoFileFormPageState extends State<VideoFileFormPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  VideoModel? video;

  Future<void> init() async {
    video = context.read<VideoProvider>().getCurrentVideo;
    await context.read<VideoFileProvider>().initList(videoId: video!.id);
  }

  void _addFromPath() {
    showDialog(
      context: context,
      builder: (context) => RenameDialog(
        renameText: '',
        onCancel: () {},
        onSubmit: (dirPath) async {
          await context
              .read<VideoFileProvider>()
              .addFromPath(videoId: video!.id, dirPath: dirPath);
        },
      ),
    );
  }

  void _addFormPathList(List<String> pathList) async {
    await context
        .read<VideoFileProvider>()
        .addFromPathList(videoId: video!.id, pathList: pathList);
  }

  Future<void> _setCover(VideoFileModel videoFile) async {
    final file = File(videoFile.coverPath);
    final oldCover =
        File('${VideoServices.instance.getSourcePath(video!.id)}/cover.png');
    if (await oldCover.exists()) {
      await oldCover.delete();
    }
    if (await file.exists()) {
      await file.copy(oldCover.path);
    }
    //clean image cache
    await clearAndRefreshImage();

    if (!mounted) return;
    showMessage(context, 'Set Cover Success');
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 150,
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.add),
                title: Text(
                    'Add From Path (${appConfigNotifier.value.isMoveVideoFileWithInfo ? 'File ပါရွှေ့မယ်' : 'Info ရယူမယ်'})'),
                onTap: () {
                  Navigator.pop(context);
                  _addFromPath();
                },
              ),
              ListTile(
                leading: Icon(Icons.add),
                title: Text(
                    'Add From Chooser (${appConfigNotifier.value.isMoveVideoFileWithInfo ? 'File ပါရွှေ့မယ်' : 'Info ရယူမယ်'})'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoScannerScreen(
                        onChoosed: _addFormPathList,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(VideoFileModel videoFile) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 150,
          ),
          child: Column(
            children: [
              //delete
              ListTile(
                iconColor: dangerColor,
                textColor: dangerColor,
                leading: Icon(Icons.delete_forever),
                title: Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => ConfirmDialog(
                      contentText:
                          '`${videoFile.title}` ကိုသင်ဖျက်ချင်တာ သေချာပြီလား',
                      onCancel: () {},
                      onSubmit: () async {
                        context.read<VideoFileProvider>().delete(
                              videoFile: videoFile,
                              videoId: video!.id,
                            );
                      },
                    ),
                  );
                },
              ),
              //export video
              ListTile(
                leading: Icon(Icons.import_export),
                title: Text('အပြင်ကို ပြန်ထုတ်မယ်'),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<VideoFileProvider>()
                      .moveOutVideoFileAndRemoveInfo(
                        videoId: video!.id,
                        videoFile: videoFile,
                      );
                },
              ),
              //set cover
              ListTile(
                leading: Icon(Icons.save_alt_sharp),
                title: Text('Set Cover'),
                onTap: () {
                  Navigator.pop(context);
                  _setCover(videoFile);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VideoFileProvider>();
    final isLoading = provider.isLoading;
    final videoFileList = provider.getList;
    return MyScaffold(
      contentPadding: 2,
      body: isLoading
          ? Center(child: TLoader())
          : RefreshIndicator(
              onRefresh: () async {
                await init();
              },
              child: VideoFileListView(
                list: videoFileList,
                onLongClick: _showContextMenu,
                onClick: (videoFile) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(video: videoFile),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMenu,
        child: Icon(Icons.add),
      ),
    );
  }
}
