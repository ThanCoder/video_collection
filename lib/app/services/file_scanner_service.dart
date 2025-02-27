import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:video_collection/app/extensions/index.dart';

class FileScannerService {
  //for singleton
  static final FileScannerService instance = FileScannerService._();
  FileScannerService._();
  factory FileScannerService() => instance;

  List<String> skipList = ['.', 'Android', 'DCIM', 'Pictures'];
  List<String> linuxScanFolder = ['Videos', 'Downloads', 'Documents'];

  Future<List<String>> getList({String initPath = ''}) async {
    List<String> list = [];
    try {
      var rootPath = await ThanPkg.platform.getAppExternalPath();
      if (Platform.isLinux) {
        rootPath = '$rootPath/Videos';
      }
      //init path
      if (initPath.isNotEmpty) {
        rootPath = initPath;
      }
      if (rootPath == null) return list;

      list = await Isolate.run<List<String>>(() async {
        List<String> _list = [];

        try {
          void scan(String path) {
            final dir = Directory(path);
            for (var file in dir.listSync()) {
              //skip folder
              if (file.getName().startsWith('.') ||
                  skipList.contains(file.getName())) {
                debugPrint('skip: ${file.getName()}');
                continue;
              }

              if (file.isDirectory()) {
                scan(file.path);
                continue;
              }
              //video file ဖြစ်နေလား စစ်မယ်
              if (!isVideoFile(file.path)) continue;
              //video file ဖြစ်နေရင်
              _list.add(file.path);
            }
          }

          if (Platform.isLinux) {
            final linuxRootPath = await ThanPkg.platform.getAppExternalPath();
            for (var path in linuxScanFolder) {
              scan('$linuxRootPath/$path');
            }
          } else {
            scan(rootPath!);
          }
        } catch (e) {
          debugPrint('scan-isolate: ${e.toString()}');
        }
        //sort
        _list.sort((a, b) {
          final af = File(a);
          final bf = File(b);
          return af
              .statSync()
              .modified
              .millisecondsSinceEpoch
              .compareTo(bf.statSync().modified.millisecondsSinceEpoch);
        });

        return _list;
      });
    } catch (e) {
      debugPrint('getList: ${e.toString()}');
    }
    return list;
  }

  bool isVideoFile(String path) {
    final res = lookupMimeType(path);
    if (res == null) return false;
    return res.startsWith('video');
  }
}
