// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:mime/mime.dart';
import 'package:video_collection/app/extensions/index.dart';

class VideoScannerModel {
  String name;
  String path;
  String mime;
  int size;
  int date;

  bool isSelected = false;
  VideoScannerModel({
    required this.name,
    required this.path,
    required this.mime,
    required this.size,
    required this.date,
  });

  factory VideoScannerModel.fromPath(String path) {
    final file = File(path);
    return VideoScannerModel(
      name: file.getName(),
      path: path,
      mime: lookupMimeType(path) ?? '',
      size: file.statSync().size,
      date: file.statSync().modified.millisecondsSinceEpoch,
    );
  }

  @override
  String toString() {
    return name;
  }
}
