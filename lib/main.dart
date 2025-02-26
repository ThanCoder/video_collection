import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:video_collection/app/proviers/index.dart';

import 'app/my_app.dart';
import 'app/services/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThanPkg.windowManagerensureInitialized();

  //init config
  await initAppConfigService();
  //media player
  MediaKit.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => VideoProvider()),
        ChangeNotifierProvider(create: (context) => VideoFileProvider()),
        // ChangeNotifierProvider(create: (context) => ()),
      ],
      child: const MyApp(),
    ),
  );
}
