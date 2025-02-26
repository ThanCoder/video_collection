import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_collection/app/proviers/index.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VideoFileProvider>();
    final isLoading = provider.isLoading;
    // final contentFileList = provider.getList;

    return MyScaffold(
      body: isLoading ? Center(child: TLoader()) : Text('data'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
