import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:video_collection/app/constants.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/utils/index.dart';

class ContentFileService {
  static final ContentFileService instance = ContentFileService._init();
  ContentFileService._init();
  factory ContentFileService() => instance;

  Future<List<ContentFileModel>> getList({required String videoId}) async {
    List<ContentFileModel> list = [];
    try {
      final dirPath = createDir('${getDatabaseSourcePath()}/$videoId');
      final path = '$dirPath/$appVideoContentCoverDatabaseName';
      //isolate
      list = await Isolate.run<List<ContentFileModel>>(() async {
        List<ContentFileModel> _list = [];
        final dbFile = File(path);

        if (dbFile.existsSync()) {
          List<dynamic> resList = jsonDecode(await dbFile.readAsString());
          _list = resList.map((map) => ContentFileModel.fromMap(map)).toList();
        }
        return _list;
      });
    } catch (e) {
      debugPrint('getList: ${e.toString()}');
    }
    return list;
  }

  Future<void> setList(
      {required String videoId, required List<ContentFileModel> list}) async {
    try {
      final dirPath = createDir('${getDatabaseSourcePath()}/$videoId');
      final dbFile = File('$dirPath/$appVideoContentCoverDatabaseName');
      //to json
      final data = list.map((vd) => vd.toMap()).toList();
      await dbFile.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('setList: ${e.toString()}');
    }
  }
}
