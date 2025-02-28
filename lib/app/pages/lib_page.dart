import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_collection/app/components/index.dart';
import 'package:video_collection/app/enums/video_types.dart';
import 'package:video_collection/app/extensions/string_extension.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/proviers/index.dart';
import 'package:video_collection/app/screens/index.dart';
import 'package:video_collection/app/services/index.dart';
import 'package:video_collection/app/widgets/core/index.dart';

class LibPage extends StatefulWidget {
  const LibPage({super.key});

  @override
  State<LibPage> createState() => _LibPageState();
}

class _LibPageState extends State<LibPage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  bool isLoading = false;
  int takeLimit = 5;
  List<VideoFileModel> allVideoFileList = [];
  List<VideoModel> allVideoList = [];
  List<VideoFileModel> latestVideoFileList = [];
  List<VideoModel> movieList = [];
  List<VideoModel> musicList = [];
  List<VideoModel> pornsList = [];
  List<VideoModel> seriesList = [];

  void init() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });
    allVideoFileList = await VideoFileService.instance.getAllVideoList();
    allVideoList = await VideoServices.instance.getVideoList();

    latestVideoFileList = allVideoFileList.take(takeLimit).toList();

    //get videos type
    final types = allVideoList.map((vd) => vd.type).toSet();

    for (var type in types) {
      if (type == VideoTypes.movie) {
        //fitler movie id
        final idSet = allVideoList
            .where((vd) => vd.type == type)
            .map((vd) => vd.id)
            .toSet();
        movieList = allVideoList
            .where((vd) => idSet.contains(vd.id))
            .take(takeLimit)
            .toList();
      } else if (type == VideoTypes.music) {
        final idSet = allVideoList
            .where((vd) => vd.type == type)
            .map((vd) => vd.id)
            .toSet();
        musicList = allVideoList
            .where((vd) => idSet.contains(vd.id))
            .take(takeLimit)
            .toList();
      } else if (type == VideoTypes.porns) {
        final idSet = allVideoList
            .where((vd) => vd.type == type)
            .map((vd) => vd.id)
            .toSet();
        pornsList = allVideoList
            .where((vd) => idSet.contains(vd.id))
            .take(takeLimit)
            .toList();
      } else if (type == VideoTypes.series) {
        final idSet = allVideoList
            .where((vd) => vd.type == type)
            .map((vd) => vd.id)
            .toSet();
        seriesList = allVideoList
            .where((vd) => idSet.contains(vd.id))
            .take(takeLimit)
            .toList();
      }
    }
    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  List<VideoModel> _getListFromType(VideoTypes type) {
    if (type == VideoTypes.movie) {
      return movieList;
    } else if (type == VideoTypes.music) {
      return musicList;
    } else if (type == VideoTypes.porns) {
      return pornsList;
    } else if (type == VideoTypes.series) {
      return seriesList;
    }

    return [];
  }

  List<Widget> _getListWidget() {
    return List.generate(
      VideoTypes.values.length,
      (index) {
        final type = VideoTypes.values[index];
        final list = _getListFromType(type);
        return VideoSeeAllListView(
          title: type.name.toCaptalize(),
          list: list,
          onClick: (video) {
            context.read<VideoProvider>().setCurrentVideo(video);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoContentScreen(),
              ),
            );
          },
          onSeeAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllVideoScreen(
                  title: type.name.toCaptalize(),
                  list: list,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        // contentPadding: 2,
        appBar: AppBar(
          title: Text('Book Mark'),
        ),
        body: isLoading
            ? TLoader()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    //latest
                    VideoFileSeeAllListView(
                      title: 'Video အသစ်များ',
                      list: latestVideoFileList,
                      onClick: (video) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VideoPlayerScreen(video: video),
                          ),
                        );
                      },
                      onSeeAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllVideoFileScreen(
                                title: 'Video အားလုံး', list: allVideoFileList),
                          ),
                        );
                      },
                    ),
                    ..._getListWidget(),
                  ],
                ),
              ));
  }
}
