import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:video_collection/app/components/index.dart';
import 'package:video_collection/app/dialogs/index.dart';
import 'package:video_collection/app/services/index.dart';

class ContentFileProvider with ChangeNotifier {
  final List<String> _list = [];
  bool _isLoading = false;
  String? _currentVideoFile;

  List<String> get getList => _list;
  String? get getCurrentVideoFile => _currentVideoFile;
  bool get isLoading => _isLoading;

  Future<void> initList({required String videoId}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final res = await ContentFileService.instance.getList(videoId: videoId);
      //clear && add
      _list.clear();
      _list.addAll(res);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('initList: ${e.toString()}');
    }
  }

  Future<void> deleteWithConfirm(
    BuildContext context, {
    required String videoId,
    required String name,
  }) async {
    showDialog(
      context: context,
      builder: (ctx) => ConfirmDialog(
        contentText: '`$name` ကိုဖျက်ချင်တာ သေချာပြီလား?',
        submitText: 'ဖျက်မယ်',
        onCancel: () {},
        onSubmit: () async {
          try {
            _isLoading = true;
            notifyListeners();
            final res = _list.where((n) => n != name).toList();

            //clear && add
            _list.clear();
            _list.addAll(res);
            //set data
            await ContentFileService.instance
                .setList(videoId: videoId, list: _list);

            _isLoading = false;
            notifyListeners();
            //show mess
            showMessage(ctx, 'ဖျက်ပြီးပါပြီ');
          } catch (e) {
            _isLoading = false;
            notifyListeners();
            debugPrint('deleteWithConfirm: ${e.toString()}');
          }
        },
      ),
    );
  }

  Future<void> addFromPath({required String videoId}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final res = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        dialogTitle: 'Fick Cover',
        type: FileType.image,
      );
      if (res != null && res.files.isNotEmpty) {
        for (var file in res.files) {
          //new file
          final id = Uuid().v4();
          final contentFilePath =
              '${VideoServices.instance.getSourcePath(videoId)}/$id.png';
          final coverFile = File(file.path!);
          if (await coverFile.exists()) {
            await coverFile.copy(contentFilePath);
          }
          _list.add('$id.png');
        }
      }
      //set db
      await ContentFileService.instance.setList(list: _list, videoId: videoId);
      //init
      await initList(videoId: videoId);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('addFromPath: ${e.toString()}');
    }
  }
}
