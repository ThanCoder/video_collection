import 'package:flutter/material.dart';
import 'package:video_collection/app/components/index.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/services/index.dart';
import 'package:video_collection/app/widgets/index.dart';

ValueNotifier<bool> _isLoading = ValueNotifier(false);

class VideoSearchDelegate extends SearchDelegate {
  List<VideoFileModel> videoFilesList = [];
  void Function(VideoFileModel videoFile) onClicked;

  VideoSearchDelegate({required this.onClicked}) {
    _init();
  }
  void _init() async {
    _isLoading.value = true;
    videoFilesList = await VideoFileService.instance.getAllVideoList();
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
    final list = videoFilesList
        .where((vf) => vf.title.toUpperCase().contains(query.toUpperCase()))
        .toList();
    return VideoFileListView(
      list: list,
      onClick: onClicked,
    );
  }
}
