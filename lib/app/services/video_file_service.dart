import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:video_collection/app/constants.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/services/video_services.dart';

class VideoFileService {
  static final VideoFileService instance = VideoFileService._init();
  VideoFileService._init();
  factory VideoFileService() => instance;

  Future<List<VideoFileModel>> getList({required String videoId}) async {
    List<VideoFileModel> list = [];
    try {
      final path =
          '${VideoServices.instance.getSourcePath(videoId)}/$appVideoFileDatabaseName';
      //isolate
      list = await Isolate.run<List<VideoFileModel>>(() async {
        List<VideoFileModel> _list = [];
        final dbFile = File(path);

        if (dbFile.existsSync()) {
          List<dynamic> resList = jsonDecode(await dbFile.readAsString());
          _list = resList.map((map) => VideoFileModel.fromMap(map)).toList();
        }
        return _list;
      });
    } catch (e) {
      debugPrint('getList: ${e.toString()}');
    }
    return list;
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
