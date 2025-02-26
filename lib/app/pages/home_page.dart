import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_collection/app/components/video_list_view.dart';
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
              print(selectedPath);
            },
          ),
        ));
  }

  void _createVideoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => RenameDialog(
        title: 'New Video',
        onCancel: () {},
        onSubmit: (text) {
          if (text.isEmpty) return;
          final video = VideoModel(
            id: Uuid().v4(),
            title: text,
            genres: '',
            desc: '',
            date: DateTime.now().millisecondsSinceEpoch,
            type: VideoTypes.movie,
          );
          context.read<VideoProvider>().add(video: video);
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
