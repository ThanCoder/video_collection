import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:uuid/uuid.dart';
import 'package:video_collection/app/extensions/index.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/notifiers/app_notifier.dart';
import 'package:video_collection/app/services/index.dart';
import 'package:video_collection/app/utils/index.dart';

class VideoFileProvider with ChangeNotifier {
  final List<VideoFileModel> _list = [];
  bool _isLoading = false;
  VideoFileModel? _currentVideoFile;

  List<VideoFileModel> get getList => _list;
  VideoFileModel? get getCurrentVideoFile => _currentVideoFile;
  bool get isLoading => _isLoading;

  Future<void> setCurrentVideo(VideoFileModel videoFile) async {
    _currentVideoFile = videoFile;
    notifyListeners();
  }

  Future<void> moveOutVideoFileAndRemoveInfo({
    required String videoId,
    required VideoFileModel videoFile,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      //move file
      final file = File(
          '${VideoServices.instance.getSourcePath(videoId)}/${videoFile.id}');
      if (await file.exists()) {
        final outpath = '${getOutPath()}/${videoFile.title}';
        await file.rename(outpath);
      }
      //remove ui
      final res = _list.where((vf) => vf.id != videoFile.id).toList();
      //delete db
      await VideoFileService.instance.setList(videoId: videoId, list: res);

      //clear && add
      _list.clear();
      _list.addAll(res);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('moveOutVideoFileAndRemoveInfo: ${e.toString()}');
    }
  }

  Future<void> delete({
    required VideoFileModel videoFile,
    required String videoId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      //remove ui
      final res = _list.where((vf) => vf.id != videoFile.id).toList();
      //delete db
      await VideoFileService.instance.setList(videoId: videoId, list: res);
      //delete file
      final file = File(videoFile.path);
      if (await file.exists()) {
        await file.delete();
      }

      _list.clear();
      _list.addAll(res);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('deleteWithConfirm: ${e.toString()}');
    }
  }

  Future<void> initList({required String videoId}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final res = await VideoFileService.instance.getList(videoId: videoId);
      //clear && add
      _list.clear();
      _list.addAll(res);

      await genCover();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('initList: ${e.toString()}');
    }
  }

  Future<void> update(
      {required String videoId, required VideoFileModel videoFile}) async {
    try {
      _isLoading = true;
      notifyListeners();
      //change ui
      final resList = _list.map((vd) {
        if (vd.id == videoFile.id) {
          vd = videoFile;
        }
        return vd;
      }).toList();
      //db
      // final list = await VideoFileService.instance.getVideoList();
      _list.clear();
      _list.addAll(resList);

      await VideoFileService.instance.setList(videoId: videoId, list: resList);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('update: ${e.toString()}');
    }
  }

  Future<void> addFromPathList({
    required String videoId,
    required List<String> pathList,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      //ရှိပြီးသား video title list
      final titleList = _list.map((vd) => vd.title).toSet();

      for (var path in pathList) {
        //check mime
        final mime = lookupMimeType(path);
        if (mime == null || !mime.startsWith('video')) continue;
        //video title ရှိပြီးသားလား ထပ်စစ်
        final isExists = titleList.contains(path.getName());
        //ရှိရင် ကျော်မယ်
        if (isExists) continue;
        //video id
        final id = Uuid().v4();

        //check config
        bool isMoveVideoFile = appConfigNotifier.value.isMoveVideoFileWithInfo;
        final videoFile = File(path);
        final videoFileSize = videoFile.statSync().size;
        final videoMovePath =
            '${VideoServices.instance.getSourcePath(videoId)}/$id';
        if (isMoveVideoFile) {
          await videoFile.rename(videoMovePath);
        }

        //is video file
        final newVideo = VideoFileModel(
          id: id,
          title: path.getName(),
          coverPath: '${getCachePath()}/$id.png',
          path: isMoveVideoFile ? videoMovePath : path,
          size: videoFileSize,
          date: DateTime.now().millisecondsSinceEpoch,
        );
        //add ui
        _list.add(newVideo);
      }
      //sort
      _list.sort((a, b) => a.title.compareTo(b.title));

      await VideoFileService.instance.setList(videoId: videoId, list: _list);

      await genCover();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('addFromPathList: ${e.toString()}');
    }
  }

  Future<void> addFromPath({
    required String videoId,
    required String dirPath,
  }) async {
    try {
      final dir = Directory(dirPath);
      if (!await dir.exists()) return;
      _isLoading = true;
      notifyListeners();
      //ရှိပြီးသား video title list
      final titleList = _list.map((vd) => vd.title).toSet();

      for (var file in dir.listSync()) {
        if (file.statSync().type != FileSystemEntityType.file) continue;
        //check mime
        final mime = lookupMimeType(file.path);
        if (mime == null || !mime.startsWith('video')) continue;
        //video title ရှိပြီးသားလား ထပ်စစ်
        final isExists = titleList.contains(file.getName());
        //ရှိရင် ကျော်မယ်
        if (isExists) continue;
        //video id
        final id = Uuid().v4();

        //check config
        bool isMoveVideoFile = appConfigNotifier.value.isMoveVideoFileWithInfo;
        //video file
        final videoFile = File(file.path);
        final videoFileSize = videoFile.statSync().size;
        final videoMovePath =
            '${VideoServices.instance.getSourcePath(videoId)}/$id';
        if (isMoveVideoFile) {
          await videoFile.rename(videoMovePath);
        }

        //is video file
        final newVideo = VideoFileModel(
          id: id,
          title: file.getName(),
          coverPath: '${getCachePath()}/$id.png',
          path: isMoveVideoFile ? videoMovePath : file.path,
          size: videoFileSize,
          date: DateTime.now().millisecondsSinceEpoch,
        );
        //add ui
        _list.add(newVideo);
      }
      //sort
      _list.sort((a, b) => a.title.compareTo(b.title));

      await VideoFileService.instance.setList(videoId: videoId, list: _list);

      await genCover();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('addFromPath: ${e.toString()}');
    }
  }

  Future<void> genCover() async {
    try {
      await ThanPkg.platform.genVideoCover(
        outDirPath: getCachePath(),
        videoPathList: _list.map((vd) => vd.path).toList(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('genCover: ${e.toString()}');
    }
  }
}
