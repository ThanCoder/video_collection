import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:video_collection/app/components/video_file_list_view.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/screens/index.dart';
import 'package:video_collection/app/utils/index.dart';
import 'package:video_collection/app/widgets/index.dart';

class AllVideoFileScreen extends StatefulWidget {
  String title;
  List<VideoFileModel> list;
  AllVideoFileScreen({super.key, required this.title, required this.list});

  @override
  State<AllVideoFileScreen> createState() => _AllVideoFileScreenState();
}

class _AllVideoFileScreenState extends State<AllVideoFileScreen> {
  @override
  void initState() {
    super.initState();
  }

  void init() async {
    //gen cover
    await ThanPkg.platform.genVideoCover(
      outDirPath: getCachePath(),
      videoPathList: widget.list.map((vf) => vf.path).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      contentPadding: 2,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: VideoFileListView(
        list: widget.list,
        onClick: (video) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(video: video),
            ),
          );
        },
      ),
    );
  }
}
