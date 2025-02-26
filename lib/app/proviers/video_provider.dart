import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_collection/app/dialogs/index.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/services/index.dart';

class VideoProvider with ChangeNotifier {
  final List<VideoModel> _list = [];
  bool _isLoading = false;
  VideoModel? _currentVideo;

  List<VideoModel> get getList => _list;
  VideoModel? get getCurrentVideo => _currentVideo;
  bool get isLoading => _isLoading;

  Future<void> setCurrentVideo(VideoModel video) async {
    _currentVideo = video;
    notifyListeners();
  }

  Future<void> initList() async {
    try {
      _isLoading = true;
      notifyListeners();

      final res = await VideoServices.instance.getVideoList();
      //clear && add
      _list.clear();
      _list.addAll(res);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('initList: ${e.toString()}');
    }
  }

  Future<void> update({required VideoModel video}) async {
    try {
      _isLoading = true;
      notifyListeners();
      //change ui
      final resList = _list.map((vd) {
        if (vd.id == video.id) {
          vd = video;
        }
        return vd;
      }).toList();
      //db
      // final list = await VideoServices.instance.getVideoList();
      _list.clear();
      _list.addAll(resList);

      await VideoServices.instance.setVideoList(list: resList);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('update: ${e.toString()}');
    }
  }

  Future<void> add({required VideoModel video}) async {
    try {
      _isLoading = true;
      notifyListeners();
      //add ui
      _list.insert(0, video);
      //db
      final list = await VideoServices.instance.getVideoList();
      list.insert(0, video);
      await VideoServices.instance.setVideoList(list: list);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('add: ${e.toString()}');
    }
  }

  Future<void> deleteWithConfirm(
    BuildContext context, {
    required VideoModel video,
    required VoidCallback onDoned,
  }) async {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText: '`${video.title} ကိုဖျက်ချင်တာ သေချာပြီလား`',
        onCancel: () {},
        onSubmit: () async {
          try {
            _isLoading = true;
            notifyListeners();
            //delete source
            final srcDir =
                Directory(VideoServices.instance.getSourcePath(video.id));
            if (await srcDir.exists()) {
              await srcDir.delete(recursive: true);
            }

            //filter
            final res = _list.where((vd) => vd.id != video.id).toList();

            //remove ui
            _list.clear();
            _list.addAll(res);
            //delete db
            await VideoServices.instance.setVideoList(list: res);

            _isLoading = false;
            notifyListeners();
            onDoned();
          } catch (e) {
            debugPrint('delete: ${e.toString()}');
          }
        },
      ),
    );
  }
}
