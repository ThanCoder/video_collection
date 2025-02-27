import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:video_collection/app/constants.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/utils/path_util.dart';

class VideoFileBookmarkService {
  static final VideoFileBookmarkService instance = VideoFileBookmarkService._();
  VideoFileBookmarkService._();
  factory VideoFileBookmarkService() => instance;

  String getDBPath() {
    return '${getDatabasePath()}/$appVideoFileBookmarkDatabaseName';
  }

  Future<void> toggle({required VideoFileBookmarkModel bookmark}) async {
    if (await isExists(title: bookmark.title)) {
      //remove
      delete(bookmark: bookmark);
    } else {
      //add
      add(bookmark: bookmark);
    }
  }

  Future<bool> isExists({required String title}) async {
    List<VideoFileBookmarkModel> list = await getList();
    final index = list.indexWhere((bf) => bf.title == title);
    return index != -1;
  }

  Future<void> delete({required VideoFileBookmarkModel bookmark}) async {
    final path = getDBPath();
    List<VideoFileBookmarkModel> list = await getList();

    await Isolate.run(() async {
      try {
        final dbFile = File(path);
        list = list.where((bf) => bf.title != bookmark.title).toList();
        //to map
        final mapList = list.map((bf) => bf.toMap()).toList();
        await dbFile.writeAsString(jsonEncode(mapList));
      } catch (e) {
        debugPrint('delete: ${e.toString()}');
      }
    });
  }

  Future<void> add({required VideoFileBookmarkModel bookmark}) async {
    final path = getDBPath();
    List<VideoFileBookmarkModel> list = await getList();

    await Isolate.run(() async {
      try {
        final dbFile = File(path);
        list.insert(0, bookmark);
        //to map
        final mapList = list.map((bf) => bf.toMap()).toList();
        await dbFile.writeAsString(jsonEncode(mapList));
      } catch (e) {
        debugPrint('add: ${e.toString()}');
      }
    });
  }

  Future<List<VideoFileBookmarkModel>> getList() async {
    final path = getDBPath();
    return await Isolate.run<List<VideoFileBookmarkModel>>(() async {
      List<VideoFileBookmarkModel> list = [];
      try {
        final dbFile = File(path);
        if (await dbFile.exists()) {
          List<dynamic> resList = jsonDecode(await dbFile.readAsString());
          list = resList
              .map((map) => VideoFileBookmarkModel.fromMap(map))
              .toList();
        }
      } catch (e) {
        debugPrint('getList: ${e.toString()}');
      }
      return list;
    });
  }
}
