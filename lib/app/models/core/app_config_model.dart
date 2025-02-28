// ignore_for_file: public_member_api_docs, sort_constructors_first
class AppConfigModel {
  bool isUseCustomPath;
  String customPath;
  bool isDarkTheme;
  bool isMoveVideoFileWithInfo;
  bool isShowAtLeastOneSingleVideoFile;

  AppConfigModel({
    this.isUseCustomPath = false,
    this.customPath = '',
    this.isDarkTheme = false,
    this.isMoveVideoFileWithInfo = false,
    this.isShowAtLeastOneSingleVideoFile = false,
  });

  factory AppConfigModel.fromJson(Map<String, dynamic> map) {
    return AppConfigModel(
      isUseCustomPath: map['is_use_custom_path'] ?? '',
      customPath: map['custom_path'] ?? '',
      isDarkTheme: map['is_dark_theme'] ?? false,
      isMoveVideoFileWithInfo: map['is_move_video_file_with_info'] ?? false,
      isShowAtLeastOneSingleVideoFile:
          map['is_show_at_least_one_single_video_file'] ?? false,
    );
  }
  Map<String, dynamic> toJson() => {
        'is_use_custom_path': isUseCustomPath,
        'custom_path': customPath,
        'is_dark_theme': isDarkTheme,
        'is_move_video_file_with_info': isMoveVideoFileWithInfo,
        'is_show_at_least_one_single_video_file':
            isShowAtLeastOneSingleVideoFile,
      };

  @override
  String toString() {
    return '\ncustom_path: $customPath\n';
  }
}
