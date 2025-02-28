// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:video_collection/app/enums/video_file_info_types.dart';

class VideoFileModel {
  String id;
  String videoId;
  String title;
  String coverPath;
  String path;
  int size;
  int date;
  VideoFileInfoTypes type;
  String desc;

  bool isSelected = false;

  VideoFileModel({
    required this.id,
    required this.videoId,
    required this.title,
    this.coverPath = '',
    required this.path,
    required this.size,
    required this.date,
    this.type = VideoFileInfoTypes.info,
    this.desc = '',
  });

  factory VideoFileModel.fromMap(
    Map<String, dynamic> map, {
    String videoId = '',
  }) {
    var vId = map['video_id'] ?? '';
    if (videoId.isNotEmpty) {
      vId = videoId;
    }
    final typeName = map['type'] ?? '';
    var type = getType(typeName);

    return VideoFileModel(
      id: map['id'],
      videoId: vId,
      title: map['title'],
      coverPath: map['cover_path'],
      path: map['path'],
      size: map['size'] ?? 0,
      date: map['date'],
      type: type,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'video_id': videoId,
        'title': title,
        'cover_path': coverPath,
        'path': path,
        'size': size,
        'date': date,
        'type': type.name,
      };
  @override
  String toString() {
    return title;
  }
}
