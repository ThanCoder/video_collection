import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_collection/app/components/video_list_view.dart';
import 'package:video_collection/app/customs/video_search_delegate.dart';
import 'package:video_collection/app/dialogs/index.dart';
import 'package:video_collection/app/enums/video_types.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/notifiers/app_notifier.dart';
import 'package:video_collection/app/proviers/index.dart';
import 'package:video_collection/app/screens/index.dart';

import '../constants.dart';
import '../widgets/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    await context.read<VideoProvider>().initList();
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 150),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.add),
                title: Text('New Video'),
                onTap: () {
                  Navigator.pop(context);
                  _createVideoDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.add),
                title: Text(
                    'Add From Chooser (${appConfigNotifier.value.isMoveVideoFileWithInfo ? 'File ပါရွှေ့မယ်' : 'Info ရယူမယ်'})'),
                onTap: () {
                  Navigator.pop(context);
                  _addFromScanner();
                },
              ),
              Platform.isLinux
                  ? ListTile(
                      leading: Icon(Icons.add),
                      title: Text(
                          'Add From File Selector (${appConfigNotifier.value.isMoveVideoFileWithInfo ? 'File ပါရွှေ့မယ်' : 'Info ရယူမယ်'})'),
                      onTap: () {
                        Navigator.pop(context);
                        _addFromFileChooser();
                      },
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  void _addFromScanner() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoScannerScreen(
            onChoosed: (selectedPath) {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => VideoTypesDialog(
                  onChoosed: (type) {
                    context.read<VideoProvider>().addFromPathList(
                          pathList: selectedPath,
                          videoType: type,
                        );
                  },
                ),
              );
            },
          ),
        ));
  }

  void _addFromFileChooser() async {
    try {
      final res = await FilePicker.platform.pickFiles(
          dialogTitle: 'Fick Videos',
          type: FileType.video,
          allowMultiple: true);
      if (res == null || res.files.isEmpty) return;
      final pathList = res.files.map((f) => f.path!).toList();

      if (!mounted) return;

      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => VideoTypesDialog(
          onChoosed: (type) {
            context.read<VideoProvider>().addFromPathList(
                  pathList: pathList,
                  videoType: type,
                );
          },
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _createVideoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => RenameDialog(
        title: 'New Video',
        onCancel: () {},
        onSubmit: (text) async {
          if (text.isEmpty) return;
          final video = VideoModel(
            id: Uuid().v4(),
            title: text,
            genres: '',
            desc: '',
            date: DateTime.now().millisecondsSinceEpoch,
            type: VideoTypes.movie,
          );
          await context.read<VideoProvider>().add(video: video);
          if (!mounted) return;
          //go form
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoFormScreen(),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VideoProvider>();
    final isLoading = provider.isLoading;
    final videoList = provider.getList;
    return MyScaffold(
      appBar: AppBar(
        title: Text(appTitle),
        actions: [
          //search
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: VideoSearchDelegate(
                  onClicked: (videoFile) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VideoPlayerScreen(video: videoFile),
                      ),
                    );
                  },
                ),
              );
            },
            icon: Icon(Icons.search),
          ),

          IconButton(
            onPressed: _showMenu,
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: TLoader())
          : RefreshIndicator(
              onRefresh: () async {
                await init();
              },
              child: VideoListView(
                list: videoList,
                onClick: (video) async {
                  context.read<VideoProvider>().setCurrentVideo(video);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoContentScreen(),
                    ),
                  );
                },
              ),
            ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _showMenu,
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
