import 'dart:io';

import '../constants.dart';
import '../notifiers/app_notifier.dart';

String getBasename(String path) {
  return path.split('/').last;
}

String getHomePath() {
  return createDir(appRootPathNotifier.value);
}

String getConfigPath() {
  return createDir('${getHomePath()}/config');
}

String getLibaryPath() {
  return createDir('${getHomePath()}/libary');
}

String getDatabasePath() {
  return createDir('${getHomePath()}/database');
}

String getDatabaseSourcePath() {
  return createDir('${getHomePath()}/databaseSource');
}

String getCachePath() {
  String homeDir = createDir(appConfigPathNotifier.value);
  return createDir('$homeDir/cache');
}

String getSourcePath() {
  return createDir('${getHomePath()}/source');
}

String getOutPath() {
  String download = createDir('${appExternalPathNotifier.value}/Downloads');
  return createDir('$download/${appName}_out');
}

String createDir(String path) {
  if (path.isEmpty) return path;
  final dir = Directory(path);
  if (!dir.existsSync()) {
    dir.createSync();
  }
  return path;
}
