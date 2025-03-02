import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class VideoPlayerConfigService {
  static final VideoPlayerConfigService instance = VideoPlayerConfigService._();
  VideoPlayerConfigService._();
  factory VideoPlayerConfigService() => instance;

  Future<void> deleteConfig({required String videoPath}) async {
    try {
      // final currentVideo = widget.list[currentVideoIndex];
      final configFile = File('$videoPath.json');
      if (await configFile.exists()) {
        await configFile.delete();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<int> getConfig({required String videoPath}) async {
    int res = 0;
    try {
      // final currentVideo = widget.list[currentVideoIndex];
      final configFile = File('$videoPath.json');
      if (await configFile.exists()) {
        final map = await configFile.readAsString();
        final config = jsonDecode(map);
        res = config['current_sec'] ?? 0;
        // player.seek(Duration(seconds: secs));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return res;
  }

  Future<void> setConfig(
      {required String videoPath, required int seconds}) async {
    try {
      // final currentSec = player.state.position.inSeconds;
      // final currentVideo = widget.list[currentVideoIndex];
      final configFile = File('$videoPath.json');
      final map = {'current_sec': seconds};
      await configFile.writeAsString(jsonEncode(map));
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
