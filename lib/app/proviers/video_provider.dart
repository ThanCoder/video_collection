import 'dart:io';

import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:uuid/uuid.dart';
import 'package:video_collection/app/dialogs/index.dart';
import 'package:video_collection/app/enums/video_file_info_types.dart';
import 'package:video_collection/app/enums/video_types.dart';
import 'package:video_collection/app/extensions/file_system_entity_extension.dart';
import 'package:video_collection/app/extensions/string_extension.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/notifiers/app_notifier.dart';
import 'package:video_collection/app/services/index.dart';
import 'package:video_collection/app/utils/index.dart';

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
      //set current
      _currentVideo = video;

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

  Future<void> addFromPathList({
    required List<String> pathList,
    required VideoTypes videoType,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      final allVideoList = await VideoServices.instance.getVideoList();

      //gen path list
      await ThanPkg.platform
          .genVideoCover(outDirPath: getCachePath(), videoPathList: pathList);

      for (var path in pathList) {
        //video ဖန်တီးမယ်
        final videoId = Uuid().v4();
        final newVideo = VideoModel(
          id: videoId,
          title: path.getName(withExt: false),
          genres: '',
          desc: '',
          date: DateTime.now().millisecondsSinceEpoch,
          type: videoType,
        );
        //add db

        allVideoList.insert(0, newVideo);

        //video folder src path
        final videoSrcPath = VideoServices.instance.getSourcePath(videoId);

        //copy video cover
        final oldVideoCover =
            File('${getCachePath()}/${path.getName(withExt: false)}.png');
        if (await oldVideoCover.exists()) {
          //cache ထဲက video cover ရှိနေရင်
          final newVideoCoverPath = '$videoSrcPath/cover.png';
          await oldVideoCover.copy(newVideoCoverPath);
        }
        //video file အတွက်ရေးမယ်
        List<VideoFileModel> allVideoFileList = [];
        //video file
        final vFile = File(path);

        final videoFileId = Uuid().v4();

        //check config
        bool isMoveVideoFile = appConfigNotifier.value.isMoveVideoFileWithInfo;
        final videoFileSize = vFile.statSync().size;
        //video fiel move path
        final videoMovePath = '$videoSrcPath/$videoFileId';
        //config က မှန်ရင် move
        var videoFileType = VideoFileInfoTypes.info;
        var vfDate = vFile.statSync().modified.millisecondsSinceEpoch;

        if (isMoveVideoFile) {
          //is movie type
          videoFileType = VideoFileInfoTypes.realData;
          //new date
          vfDate = vFile.statSync().modified.millisecondsSinceEpoch;
          await vFile.rename(videoMovePath);
        }

        final newVideoFile = VideoFileModel(
          id: videoFileId,
          videoId: videoId,
          title: vFile.getName(),
          coverPath: '',
          path: path,
          size: videoFileSize,
          date: vfDate,
          type: videoFileType,
        );

        allVideoFileList.insert(0, newVideoFile);

        //add ad video file
        await VideoFileService.instance.setList(
          list: allVideoFileList,
          videoId: videoId,
        );
      }

      //add db video list
      await VideoServices.instance.setVideoList(list: allVideoList);

      await initList();
    } catch (e) {
      debugPrint('addFromPathList: ${e.toString()}');
    }
  }
}
