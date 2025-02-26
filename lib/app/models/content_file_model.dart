// ignore_for_file: public_member_api_docs, sort_constructors_first
class ContentFileModel {
  String id;
  String title;
  String coverPath;
  String path;
  String date;
  ContentFileModel({
    required this.id,
    required this.title,
    required this.coverPath,
    required this.path,
    required this.date,
  });

  factory ContentFileModel.fromMap(Map<String, dynamic> map) {
    return ContentFileModel(
      id: map['id'],
      title: map['title'],
      coverPath: map['cover_path'],
      path: map['path'],
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'cover_path': coverPath,
        'path': path,
        'date': date,
      };
}
