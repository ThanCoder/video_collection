import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_collection/app/constants.dart';
import 'package:video_collection/app/utils/index.dart';

class ContentFileService {
  static final ContentFileService instance = ContentFileService._init();
  ContentFileService._init();
  factory ContentFileService() => instance;

  Future<List<String>> getList({required String videoId}) async {
    final dirPath = createDir('${getDatabaseSourcePath()}/$videoId');
    final path = '$dirPath/$appVideoContentCoverDatabaseName';
    List<String> list = [];
    try {
      final dbFile = File(path);

      if (dbFile.existsSync()) {
        List<dynamic> resList = jsonDecode(await dbFile.readAsString());
        list = resList.map((map) => map.toString()).toList();
      }
    } catch (e) {
      debugPrint('getList: ${e.toString()}');
    }
    return list;
  }

  Future<void> setList({
    required String videoId,
    required List<String> list,
  }) async {
    try {
      final dirPath = createDir('${getDatabaseSourcePath()}/$videoId');
      final dbFile = File('$dirPath/$appVideoContentCoverDatabaseName');
      //to json
      // final data = list.map((vd) => ).toList();
      await dbFile.writeAsString(jsonEncode(list));
    } catch (e) {
      debugPrint('setList: ${e.toString()}');
    }
  }
}
