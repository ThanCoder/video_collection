import 'package:flutter/material.dart';
import 'package:video_collection/app/widgets/index.dart';

class SearchComponent extends StatefulWidget {
  String text;
  void Function(String text) onChanged;
  void Function() onClosed;
  SearchComponent({
    super.key,
    required this.text,
    required this.onChanged,
    required this.onClosed,
  });

  @override
  State<SearchComponent> createState() => _SearchComponentState();
}

class _SearchComponentState extends State<SearchComponent> {
  final TextEditingController textController = TextEditingController();
  @override
  void initState() {
    textController.text = widget.text;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TTextField(
      controller: textController,
      hintText: 'Search...',
      onChanged: widget.onChanged,
    );
  }
}
