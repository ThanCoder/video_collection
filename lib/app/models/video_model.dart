// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:video_collection/app/enums/video_types.dart';

class VideoModel {
  String id;
  String title;
  String genres;
  String desc;
  int date;
  VideoTypes type;

  String coverPath = '';

  VideoModel({
    required this.id,
    required this.title,
    required this.genres,
    required this.desc,
    required this.date,
    required this.type,
  });

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    final typeName = map['type'] ?? '';
    var type = getType(typeName);

    final video = VideoModel(
      id: map['id'],
      title: map['title'],
      genres: map['genres'],
      desc: map['desc'],
      date: map['date'],
      type: type,
    );
    return video;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'genres': genres,
        'desc': desc,
        'type': type.name,
        'date': date,
      };

  @override
  String toString() {
    return title;
  }
}
