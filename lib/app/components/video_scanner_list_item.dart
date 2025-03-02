import 'package:flutter/material.dart';
import 'package:video_collection/app/extensions/index.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/notifiers/app_notifier.dart';
import 'package:video_collection/app/utils/index.dart';
import 'package:video_collection/app/widgets/core/index.dart';

class VideoScannerListItem extends StatelessWidget {
  VideoScannerModel video;
  void Function(VideoScannerModel video) onClicked;
  void Function(bool isChecked) onCheckChanged;
  VideoScannerListItem({
    super.key,
    required this.video,
    required this.onClicked,
    required this.onCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(video),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          children: [
            SizedBox(
              width: double.maxFinite,
              height: double.maxFinite,
              child: MyImageFile(
                path:
                    '${getCachePath()}/${video.path.getName(withExt: false)}.png',
                borderRadius: 5,
              ),
            ),
            //title
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkThemeNotifier.value
                        ? const Color.fromARGB(162, 0, 0, 0)
                        : const Color.fromARGB(220, 204, 204, 204),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
                  ),
                  child: Text(
                    video.name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
            //is selected

            Positioned(
              top: 0,
              left: 0,
              child: Checkbox(
                activeColor: Colors.blue,
                value: video.isSelected,
                onChanged: (value) => onCheckChanged(value!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
