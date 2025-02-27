import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_collection/app/proviers/index.dart';
import 'package:video_collection/app/services/video_services.dart';
import 'package:video_collection/app/widgets/index.dart';

class VideoContentCoverListView extends StatefulWidget {
  String videoId;
  VideoContentCoverListView({super.key, required this.videoId});

  @override
  State<VideoContentCoverListView> createState() =>
      _VideoContentCoverListViewState();
}

class _VideoContentCoverListViewState extends State<VideoContentCoverListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    await context.read<ContentFileProvider>().initList(videoId: widget.videoId);
  }

  void _viewCover(String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: MyImageFile(path: path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContentFileProvider>();
    final isLoading = provider.isLoading;
    final list = provider.getList;
    if (isLoading) {
      return Center(child: TLoader());
    }
    return //content cover
        SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          spacing: 5,
          children: List.generate(
            list.length,
            (index) {
              final path =
                  '${VideoServices.instance.getSourcePath(widget.videoId)}/${list[index]}';
              return GestureDetector(
                onTap: () => _viewCover(path),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: MyImageFile(
                      path: path,
                      borderRadius: 5,
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }
}
