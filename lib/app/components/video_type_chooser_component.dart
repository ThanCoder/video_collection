import 'package:flutter/material.dart';
import 'package:video_collection/app/enums/video_types.dart';
import 'package:video_collection/app/extensions/string_extension.dart';

class VideoTypeChooserComponent extends StatefulWidget {
  VideoTypes type;
  void Function(VideoTypes type) onChanged;
  VideoTypeChooserComponent({
    super.key,
    required this.type,
    required this.onChanged,
  });

  @override
  State<VideoTypeChooserComponent> createState() =>
      _VideoTypeChooserComponentState();
}

class _VideoTypeChooserComponentState extends State<VideoTypeChooserComponent> {
  @override
  void initState() {
    type = widget.type;
    super.initState();
  }

  late VideoTypes type;

  List<DropdownMenuItem<VideoTypes>> _getList() => VideoTypes.values
      .map(
        (type) => DropdownMenuItem<VideoTypes>(
          value: type,
          child: Text(type.name.toCaptalize()),
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return DropdownButton<VideoTypes>(
      padding: const EdgeInsets.all(7),
      borderRadius: BorderRadius.circular(4),
      value: type,
      items: _getList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          type = value;
        });
        widget.onChanged(value);
      },
    );
  }
}
