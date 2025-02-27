// ignore_for_file: public_member_api_docs, sort_constructors_first
class VideoFileModel {
  String id;
  String videoId;
  String title;
  String coverPath;
  String path;
  int size;
  int date;
  VideoFileModel({
    required this.id,
    required this.videoId,
    required this.title,
    required this.coverPath,
    required this.path,
    required this.size,
    required this.date,
  });

  factory VideoFileModel.fromMap(
    Map<String, dynamic> map, {
    String videoId = '',
  }) {
    var vId = map['video_id'] ?? '';
    if (videoId.isNotEmpty) {
      vId = videoId;
    }
    return VideoFileModel(
      id: map['id'],
      videoId: vId,
      title: map['title'],
      coverPath: map['cover_path'],
      path: map['path'],
      size: map['size'] ?? 0,
      date: map['date'],
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
      };
}
