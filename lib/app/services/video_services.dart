import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:video_collection/app/constants.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/utils/index.dart';

class VideoServices {
  static final VideoServices instance = VideoServices._init();
  VideoServices._init();
  factory VideoServices() => instance;

  Future<List<VideoModel>> getVideoList() async {
    List<VideoModel> list = [];
    try {
      final path = '${getDatabasePath()}/$appVideoDatabaseName';
      final dbSrcPath = getDatabaseSourcePath();
      //isolate
      list = await Isolate.run<List<VideoModel>>(() async {
        List<VideoModel> _list = [];
        final dbFile = File(path);

        if (dbFile.existsSync()) {
          List<dynamic> resList = jsonDecode(await dbFile.readAsString());
          _list = resList.map((map) {
            final vd = VideoModel.fromMap(map);
            vd.coverPath = '${createDir('$dbSrcPath/${vd.id}')}/cover.png';
            return vd;
          }).toList();
        }
        return _list;
      });
    } catch (e) {
      debugPrint('getVideoList: ${e.toString()}');
    }
    return list;
  }

  Future<void> setVideoList({required List<VideoModel> list}) async {
    try {
      final dbFile = File('${getDatabasePath()}/$appVideoDatabaseName');
      //to json
      final data = list.map((vd) => vd.toMap()).toList();
      await dbFile.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('setVideoList: ${e.toString()}');
    }
  }

  String getSourcePath(String videoId) {
    final dirPath = createDir('${getDatabaseSourcePath()}/$videoId');
    // final path = '$dirPath/$appVideoFileDatabaseName';
    return dirPath;
  }
}
