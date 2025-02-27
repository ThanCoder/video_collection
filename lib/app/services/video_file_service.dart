import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:video_collection/app/constants.dart';
import 'package:video_collection/app/extensions/string_extension.dart';
import 'package:video_collection/app/models/index.dart';
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

  Future<List<VideoFileModel>> getAllVideoList() async {
    final path = getDatabaseSourcePath();
    //isolate
    return await Isolate.run<List<VideoFileModel>>(() async {
      List<VideoFileModel> _list = [];
      try {
        final dir = Directory(path);
        if (!await dir.exists()) return _list;

        await for (var file in dir.list()) {
          //မဟုတ်ရင် ကျော်မယ်
          if (file.statSync().type != FileSystemEntityType.directory) continue;
          //json file ကို ဖတ်မယ်
          final dbPath = '${file.path}/$appVideoFileDatabaseName';
          final videoId = file.path.getName();

          final dbFile = File(dbPath);

          if (dbFile.existsSync()) {
            List<dynamic> resList = jsonDecode(await dbFile.readAsString());
            final res = resList
                .map((map) => VideoFileModel.fromMap(map, videoId: videoId))
                .toList();
            _list.addAll(res);
          }
        }

        //sort
        _list.sort((a, b) => a.date.compareTo(b.date));
      } catch (e) {
        debugPrint('getAllVideoList: ${e.toString()}');
      }
      return _list;
    });
  }

  Future<List<VideoFileModel>> getList({required String videoId}) async {
    final path =
        '${VideoServices.instance.getSourcePath(videoId)}/$appVideoFileDatabaseName';
    //isolate
    return await Isolate.run<List<VideoFileModel>>(() async {
      List<VideoFileModel> _list = [];
      try {
        final dbFile = File(path);

        if (dbFile.existsSync()) {
          List<dynamic> resList = jsonDecode(await dbFile.readAsString());
          _list = resList.map((map) => VideoFileModel.fromMap(map)).toList();
        }
        //sort
        _list.sort((a, b) => a.date.compareTo(b.date));
      } catch (e) {
        debugPrint('getList: ${e.toString()}');
      }
      return _list;
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
}
