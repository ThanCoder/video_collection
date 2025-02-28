import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_collection/app/components/index.dart';
import 'package:video_collection/app/constants.dart';
import 'package:video_collection/app/dialogs/index.dart';
import 'package:video_collection/app/dialogs/video_file_desc_edit_dialog.dart';
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
  bool isMultipleSelect = false;
  bool isMultipleSelectAll = false;
  bool isShowSearch = false;
  List<VideoFileModel> searchResult = [];

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
    if (await file.exists() && await oldCover.exists()) {
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

  void _deleteConfirm(VideoFileModel videoFile) {
    final provider = context.read<VideoFileProvider>();
    final deleteList = provider.getList.where((vf) => vf.isSelected).toList();
    final titleSet = deleteList.map((vf) => vf.title).toSet();

    String title = isMultipleSelect ? titleSet.join(',') : videoFile.title;
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText: '`$title` ကိုသင်ဖျက်ချင်တာ သေချာပြီလား',
        onCancel: () {},
        onSubmit: () async {
          //delete multi files
          if (isMultipleSelect) {
            provider.deleteMultiple(
                videoFileList: deleteList, videoId: video!.id);
            return;
          }
          //single file
          provider.delete(
            videoFile: videoFile,
            videoId: video!.id,
          );
        },
      ),
    );
  }

  void _showVideoFileInfoDialog(VideoFileModel videoFile) {
    showDialog(
      context: context,
      builder: (context) => VideoFileInfoTypesDialog(
          type: videoFile.type,
          onChoosed: (type) {
            final provider = context.read<VideoFileProvider>();
            if (isMultipleSelect) {
              //is multiple
              provider.updateIsSelectedToVideoFileInfoTypes(
                  videoId: video!.id, type: type);
              return;
            }
            //is single
            videoFile.type = type;
            provider.update(videoId: video!.id, videoFile: videoFile);
          }),
    );
  }

  void _setDescription(VideoFileModel videoFile) {
    showDialog(
      context: context,
      builder: (context) => VideoFileDescEditDialog(videoFile: videoFile),
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
              //multiple select
              ListTile(
                leading: Icon(isMultipleSelect ? Icons.undo : Icons.select_all),
                title: Text(isMultipleSelect
                    ? 'UnSelect All && Close'
                    : 'Multiple Select'),
                onTap: () {
                  Navigator.pop(context);
                  if (isMultipleSelect) {
                    context.read<VideoFileProvider>().setSelectedAll(false);
                    setState(() {
                      isMultipleSelectAll = false;
                    });
                  }
                  //select စလုပ်ရင် item တစ်ခုကို select လုပ်ပေးထားမယ်
                  if (!isMultipleSelect) {
                    context.read<VideoFileProvider>().setSelected(videoFile);
                  }
                  setState(() {
                    isMultipleSelect = !isMultipleSelect;
                  });
                },
              ),
              //multiple select all
              isMultipleSelect
                  ? ListTile(
                      leading: Icon(
                          isMultipleSelectAll ? Icons.undo : Icons.select_all),
                      title: Text(isMultipleSelectAll
                          ? 'UnSelect All'
                          : 'Multiple Select All'),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          isMultipleSelectAll = !isMultipleSelectAll;
                        });

                        context
                            .read<VideoFileProvider>()
                            .setSelectedAll(isMultipleSelectAll);
                      },
                    )
                  : SizedBox.shrink(),
              //delete
              ListTile(
                iconColor: dangerColor,
                textColor: dangerColor,
                leading: Icon(Icons.delete_forever),
                title: Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteConfirm(videoFile);
                },
              ),
              //export video
              ListTile(
                leading: Icon(Icons.import_export),
                title: Text('အပြင်ကို ပြန်ထုတ်မယ်'),
                onTap: () {
                  Navigator.pop(context);
                  final provider = context.read<VideoFileProvider>();
                  if (isMultipleSelect) {
                    provider.moveOutVideoFileAndRemoveInfoMultiple(
                      videoId: video!.id,
                      videoFileList: provider.getList
                          .where((vf) => vf.isSelected)
                          .toList(),
                    );
                    return;
                  }
                  //single
                  provider.moveOutVideoFileAndRemoveInfo(
                    videoId: video!.id,
                    videoFile: videoFile,
                  );
                },
              ),
              //set cover
              isMultipleSelect
                  ? SizedBox.shrink()
                  : ListTile(
                      leading: Icon(Icons.save_alt_sharp),
                      title: Text('Set Cover'),
                      onTap: () {
                        Navigator.pop(context);
                        _setCover(videoFile);
                      },
                    ),
              //set desc
              isMultipleSelect
                  ? SizedBox.shrink()
                  : ListTile(
                      leading: Icon(Icons.add),
                      title: Text('Set Description'),
                      onTap: () {
                        Navigator.pop(context);
                        _setDescription(videoFile);
                      },
                    ),
              //set video file stype
              ListTile(
                leading: Icon(Icons.add),
                title: Text('Set Info Type'),
                onTap: () {
                  Navigator.pop(context);
                  _showVideoFileInfoDialog(videoFile);
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
      appBar: AppBar(
        title: Text('Video File Form'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isShowSearch = true;
              });
              searchResult.clear();
              searchResult.addAll(videoFileList);
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      contentPadding: 2,
      body: isLoading
          ? Center(child: TLoader())
          : CustomScrollView(
              slivers: [
                //search
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  floating: false,
                  pinned: false,
                  toolbarHeight:
                      isShowSearch ? kToolbarHeight : 0, // Space ဖျက်နိုင်
                  actions: isShowSearch
                      ? [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isShowSearch = false;
                              });
                            },
                            icon: Icon(Icons.close),
                          ),
                        ]
                      : null,
                  flexibleSpace: isShowSearch
                      ? SearchComponent(
                          text: '',
                          onChanged: (text) {
                            if (text.isEmpty) return;
                            final res = videoFileList
                                .where((vf) => vf.title
                                    .toLowerCase()
                                    .contains(text.toLowerCase()))
                                .toList();
                            setState(() {
                              searchResult = res;
                            });
                          },
                          onClosed: () {
                            setState(() {
                              isShowSearch = false;
                            });
                          },
                        )
                      : null,
                ),
                //list
                SliverList.builder(
                  itemCount:
                      isShowSearch ? searchResult.length : videoFileList.length,
                  itemBuilder: (context, index) {
                    final vf = isShowSearch
                        ? searchResult[index]
                        : videoFileList[index];
                    return VideoFileListItem(
                      vf: vf,
                      onClick: (videoFile) {
                        if (isMultipleSelect) {
                          context
                              .read<VideoFileProvider>()
                              .setSelected(videoFile);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VideoPlayerScreen(video: videoFile),
                          ),
                        );
                      },
                      onLongClick: _showContextMenu,
                    );
                  },
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMenu,
        child: Icon(Icons.add),
      ),
    );
  }
}
/*
RefreshIndicator(
              onRefresh: () async {
                await init();
              },
              child: VideoFileListView(
                list: videoFileList,
                onLongClick: _showContextMenu,
                onClick: (videoFile) {
                  if (isMultipleSelect) {
                    context.read<VideoFileProvider>().setSelected(videoFile);
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(video: videoFile),
                    ),
                  );
                },
              ),
            )
*/
