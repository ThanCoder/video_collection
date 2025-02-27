// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:uuid/uuid.dart';

class VideoFileBookmarkModel {
  String id;
  String videoId;
  String videoFileId;
  String title;
  String coverPath;
  String filePath;
  int size;
  int date;
  VideoFileBookmarkModel({
    required this.id,
    required this.videoId,
    required this.videoFileId,
    required this.coverPath,
    required this.filePath,
    required this.title,
    required this.size,
    required this.date,
  });

  factory VideoFileBookmarkModel.fromMap(Map<String, dynamic> map) {
    return VideoFileBookmarkModel(
      id: Uuid().v4(),
      videoId: map['video_id'] ?? '',
      videoFileId: map['video_file_id'],
      coverPath: map['cover_path'],
      filePath: map['file_path'],
      title: map['title'],
      size: map['size'],
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'video_id': videoId,
        'video_file_id': videoFileId,
        'cover_path': coverPath,
        'file_path': filePath,
        'title': title,
        'size': size,
        'date': date,
      };
}
