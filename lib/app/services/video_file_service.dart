import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:video_collection/app/constants.dart';
import 'package:video_collection/app/enums/video_file_info_types.dart';
import 'package:video_collection/app/extensions/string_extension.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/notifiers/app_notifier.dart';
import 'package:video_collection/app/services/video_services.dart';
import 'package:video_collection/app/utils/index.dart';

class VideoFileService {
  static final VideoFileService instance = VideoFileService._init();
  VideoFileService._init();
  factory VideoFileService() => instance;

  Future<List<String>> getVideoIdList() async {
    List<String> list = [];
    final path = getDatabaseSourcePath();
    final dir = Directory(path);
    if (!await dir.exists()) return list;
    await for (var file in dir.list()) {
      //မဟုတ်ရင် ကျော်မယ်
      if (file.statSync().type != FileSystemEntityType.directory) continue;
      final videoId = file.path.getName();
      list.add(videoId);
    }
    return list;
  }

  //isolate ထဲမှာ သုံးမရပါ
  String getRealCoverPath(String videoId, VideoFileModel videoFile) {
    final srcPath = VideoServices.instance.getSourcePath(videoId);
    final cachePath = getCachePath();

    if (videoFile.type == VideoFileInfoTypes.realData) {
      videoFile.path = '$srcPath/${videoFile.id}';
      videoFile.coverPath = '$cachePath/${videoFile.id}.png';
    }
    if (videoFile.type == VideoFileInfoTypes.info) {
      videoFile.coverPath =
          '$cachePath/${videoFile.title.getName(withExt: false)}.png';
    }
    return videoFile.coverPath;
  }

  Future<List<VideoFileModel>> getAllVideoList() async {
    final cachePath = getCachePath();
    final appSourcPath = getDatabaseSourcePath();
    final isShowAtLastSingleVideoFile =
        appConfigNotifier.value.isShowAtLeastOneSingleVideoFile;
    //isolate
    return await Isolate.run<List<VideoFileModel>>(() async {
      List<VideoFileModel> list = [];
      try {
        final dir = Directory(appSourcPath);
        if (!await dir.exists()) return list;

        await for (var file in dir.list()) {
          //မဟုတ်ရင် ကျော်မယ်
          if (file.statSync().type != FileSystemEntityType.directory) continue;
          //json file ကို ဖတ်မယ်
          final dbPath = '${file.path}/$appVideoFileDatabaseName';
          final videoId = file.path.getName();
          final srcPath = '$appSourcPath/$videoId';
          final dbFile = File(dbPath);

          if (dbFile.existsSync()) {
            List<dynamic> resList = jsonDecode(await dbFile.readAsString());
            //check video cover path ကိုပြန်ပြင်ခြင်း
            var res = resList.map((map) {
              final video = VideoFileModel.fromMap(map, videoId: videoId);
              if (video.type == VideoFileInfoTypes.realData) {
                video.path = '$srcPath/${video.id}';
                video.coverPath = '$cachePath/${video.id}.png';
              }
              if (video.type == VideoFileInfoTypes.info) {
                video.coverPath =
                    '$cachePath/${video.title.getName(withExt: false)}.png';
              }
              return video;
            }).toList();
            //check video file ရှိလား
            if (isShowAtLastSingleVideoFile) {
              res = res.where((vf) => File(vf.path).existsSync()).toList();
            }
            list.addAll(res);
          }
        }

        //sort
        list.sort((a, b) => a.date.compareTo(b.date));
      } catch (e) {
        debugPrint('getAllVideoList: ${e.toString()}');
      }
      return list;
    });
  }

  Future<List<VideoFileModel>> getList({required String videoId}) async {
    final srcPath = VideoServices.instance.getSourcePath(videoId);
    final path = '$srcPath/$appVideoFileDatabaseName';
    final cachePath = getCachePath();
    final isShowAtLastSingleVideoFile =
        appConfigNotifier.value.isShowAtLeastOneSingleVideoFile;
    //isolate
    return await Isolate.run<List<VideoFileModel>>(() async {
      List<VideoFileModel> list = [];
      try {
        final dbFile = File(path);

        if (dbFile.existsSync()) {
          List<dynamic> resList = jsonDecode(await dbFile.readAsString());

          //check video file coverPath
          list = resList.map((map) {
            final video = VideoFileModel.fromMap(map);
            if (video.type == VideoFileInfoTypes.realData) {
              video.path = '$srcPath/${video.id}';
              video.coverPath = '$cachePath/${video.id}.png';
            }
            if (video.type == VideoFileInfoTypes.info) {
              video.coverPath =
                  '$cachePath/${video.title.getName(withExt: false)}.png';
            }

            return video;
          }).toList();

          //check video file ရှိလား
          if (isShowAtLastSingleVideoFile) {
            list = list.where((vf) => File(vf.path).existsSync()).toList();
          }
        }
        //sort
        list.sort((a, b) => a.date.compareTo(b.date));
      } catch (e) {
        debugPrint('getList: ${e.toString()}');
      }
      return list;
    });
  }

  Future<void> setList(
      {required String videoId, required List<VideoFileModel> list}) async {
    try {
      final dbFile = File(
          '${VideoServices.instance.getSourcePath(videoId)}/$appVideoFileDatabaseName');
      //to json
      final data = list.map((vd) => vd.toMap()).toList();
      await dbFile.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('setList: ${e.toString()}');
    }
  }

  //desc
  Future<void> setDesc({
    required VideoFileModel videoFile,
    required String text,
  }) async {
    try {
      final file = File(
          '${VideoServices.instance.getSourcePath(videoFile.videoId)}/${videoFile.id}.desc');
      await file.writeAsString(text);
    } catch (e) {
      debugPrint('setDesc: ${e.toString()}');
    }
  }

  Future<String> getDesc({required VideoFileModel videoFile}) async {
    String text = '';
    try {
      final file = File(
          '${VideoServices.instance.getSourcePath(videoFile.videoId)}/${videoFile.id}.desc');
      if (await file.exists()) {
        text = await file.readAsString();
      }
    } catch (e) {
      debugPrint('getDesc: ${e.toString()}');
    }
    return text;
  }
}
