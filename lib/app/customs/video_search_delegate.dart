import 'package:flutter/material.dart';

import 'package:video_collection/app/extensions/index.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/services/index.dart';
import 'package:video_collection/app/utils/index.dart';
import 'package:video_collection/app/widgets/index.dart';

ValueNotifier<bool> _isLoading = ValueNotifier(false);

class VideoSearchDelegate extends SearchDelegate {
  List<VideoFileModel> videoFilesList = [];
  List<VideoModel> videoList = [];
  void Function(VideoModel video) onVideoClicked;
  void Function(VideoFileModel videoFile) onVideoFileClicked;

  VideoSearchDelegate({
    required this.onVideoClicked,
    required this.onVideoFileClicked,
  }) {
    _init();
  }
  void _init() async {
    _isLoading.value = true;
    videoFilesList = await VideoFileService.instance.getAllVideoList();
    videoList = await VideoServices.instance.getVideoList();
    _isLoading.value = false;
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      query.isNotEmpty
          ? IconButton(
              onPressed: () {
                query = '';
              },
              icon: Icon(Icons.clear),
            )
          : SizedBox.shrink(),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isLoading,
      builder: (context, value, child) {
        if (value) {
          return TLoader();
        }
        return _getList();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isLoading,
      builder: (context, value, child) {
        if (value) {
          return TLoader();
        }
        return _getList();
      },
    );
  }

  Widget _getList() {
    if (query.isEmpty) {
      return Center(child: Text('တစ်ခုခုရေးပါ!'));
    }
    final vfList = videoFilesList
        .where((vf) => vf.title.toUpperCase().contains(query.toUpperCase()))
        .toList();
    final vList = videoList
        .where((vf) => vf.title.toUpperCase().contains(query.toUpperCase()))
        .toList();

    // final resultFileList = vfList.map((vf)=>);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        slivers: [
          //video
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: vList.isNotEmpty
                  ? Text(
                      'Result: Video List',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    )
                  : SizedBox(),
            ),
          ),
          SliverList.builder(
            itemCount: vList.length,
            itemBuilder: (context, index) {
              final vd = vList[index];
              return GestureDetector(
                onTap: () => onVideoClicked(vd),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Card(
                    child: Row(
                      spacing: 10,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: MyImageFile(
                            path: vd.coverPath,
                            borderRadius: 5,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(vd.title),
                              Text(vd.genres),
                              Text(vd.type.name),
                              Text(getParseDate(vd.date)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          //video file
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: vfList.isNotEmpty
                  ? Text(
                      'Result: Video Files List',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          ),
          SliverList.builder(
            itemCount: vfList.length,
            itemBuilder: (context, index) {
              final vf = vfList[index];
              return GestureDetector(
                onTap: () => onVideoFileClicked(vf),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Card(
                    color: vf.isSelected ? Colors.blue[900] : null,
                    child: Row(
                      spacing: 10,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: MyImageFile(
                            path: vf.coverPath,
                            borderRadius: 5,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            spacing: 5,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(vf.title),
                              Text('Type: ${vf.type.name.toCaptalize()}'),
                              Text(getParseFileSize(vf.size.toDouble())),
                              Text(getParseDate(vf.date)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
