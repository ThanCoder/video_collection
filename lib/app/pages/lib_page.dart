import 'package:flutter/material.dart';
import 'package:video_collection/app/components/index.dart';
import 'package:video_collection/app/enums/video_types.dart';
import 'package:video_collection/app/extensions/string_extension.dart';
import 'package:video_collection/app/models/index.dart';
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
  List<VideoFileModel> allList = [];
  List<VideoFileModel> latestList = [];
  List<VideoFileModel> movieList = [];
  List<VideoFileModel> musicList = [];
  List<VideoFileModel> pornsList = [];
  List<VideoFileModel> seriesList = [];

  void init() async {
    setState(() {
      isLoading = true;
    });
    allList = await VideoFileService.instance.getAllVideoList();
    final allVideoList = await VideoServices.instance.getVideoList();

    latestList = allList.take(5).toList();

    //get videos type
    final types = allVideoList.map((vd) => vd.type).toSet();

    for (var type in types) {
      if (type == VideoTypes.movie) {
        //fitler movie id
        final idSet = allVideoList
            .where((vd) => vd.type == type)
            .map((vd) => vd.id)
            .toSet();
        movieList = allList.where((vd) => idSet.contains(vd.videoId)).toList();
      } else if (type == VideoTypes.music) {
        final idSet = allVideoList
            .where((vd) => vd.type == type)
            .map((vd) => vd.id)
            .toSet();
        musicList = allList.where((vd) => idSet.contains(vd.videoId)).toList();
      } else if (type == VideoTypes.porns) {
        final idSet = allVideoList
            .where((vd) => vd.type == type)
            .map((vd) => vd.id)
            .toSet();
        pornsList = allList.where((vd) => idSet.contains(vd.videoId)).toList();
      } else if (type == VideoTypes.series) {
        final idSet = allVideoList
            .where((vd) => vd.type == type)
            .map((vd) => vd.id)
            .toSet();
        seriesList = allList.where((vd) => idSet.contains(vd.videoId)).toList();
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget _getListWidget() {
    return ListView(
      children: [
        //lates
        VideoFileSeeAllListView(
          title: 'Video အသစ်များ',
          list: latestList,
          onClick: (video) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(video: video),
              ),
            );
          },
          onSeeAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AllVideoFileScreen(title: 'Video အားလုံး', list: allList),
              ),
            );
          },
        ),
        //movie
        VideoFileSeeAllListView(
          title: VideoTypes.movie.name.toCaptalize(),
          list: movieList,
          onClick: (video) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(video: video),
              ),
            );
          },
          onSeeAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AllVideoFileScreen(title: 'Movies', list: movieList),
              ),
            );
          },
        ),
        //music
        VideoFileSeeAllListView(
          title: VideoTypes.music.name.toCaptalize(),
          list: musicList,
          onClick: (video) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(video: video),
              ),
            );
          },
          onSeeAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AllVideoFileScreen(title: 'Movies', list: musicList),
              ),
            );
          },
        ),
        //series
        VideoFileSeeAllListView(
          title: VideoTypes.music.name.toCaptalize(),
          list: seriesList,
          onClick: (video) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(video: video),
              ),
            );
          },
          onSeeAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllVideoFileScreen(
                    title: VideoTypes.music.name.toCaptalize(),
                    list: seriesList),
              ),
            );
          },
        ),
        //porns
        VideoFileSeeAllListView(
          title: VideoTypes.porns.name.toCaptalize(),
          list: pornsList,
          onClick: (video) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(video: video),
              ),
            );
          },
          onSeeAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AllVideoFileScreen(title: 'Porns', list: pornsList),
              ),
            );
          },
        ),
      ],
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
