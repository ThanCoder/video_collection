import 'package:flutter/material.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/screens/video_player_screen.dart';
import 'package:video_collection/app/services/index.dart';
import 'package:video_collection/app/widgets/index.dart';

class VideoFileBookmarkPage extends StatefulWidget {
  const VideoFileBookmarkPage({super.key});

  @override
  State<VideoFileBookmarkPage> createState() => _VideoFileBookmarkPageState();
}

class _VideoFileBookmarkPageState extends State<VideoFileBookmarkPage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  bool isLoading = true;
  List<VideoFileBookmarkModel> list = [];

  void init() async {
    setState(() {
      isLoading = true;
    });
    final res = await VideoFileBookmarkService.instance.getList();
    if (!mounted) return;
    setState(() {
      isLoading = false;
      list = res;
    });
  }

  void _goPlayerPage(VideoFileBookmarkModel bf) {
    final video = VideoFileModel(
      id: bf.videoFileId,
      videoId: bf.videoId,
      title: bf.title,
      coverPath: bf.coverPath,
      path: bf.filePath,
      size: bf.size,
      date: 0,
    );
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(video: video),
        ));
  }

  Widget _getListWidget() {
    return GridView.builder(
      itemCount: list.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        mainAxisExtent: 180,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
      itemBuilder: (context, index) {
        final bf = list[index];
        return GestureDetector(
          onTap: () => _goPlayerPage(bf),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: MyImageFile(
                    path: bf.coverPath,
                    borderRadius: 5,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(153, 129, 129, 129),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5),
                      ),
                    ),
                    child: Text(
                      bf.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      contentPadding: 2,
      appBar: AppBar(
        title: Text('Book Mark'),
      ),
      body: isLoading ? TLoader() : _getListWidget(),
    );
  }
}
