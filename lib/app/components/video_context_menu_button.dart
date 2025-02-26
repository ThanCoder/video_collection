import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_collection/app/proviers/index.dart';
import 'package:video_collection/app/screens/video_form_screen.dart';

class VideoContextMenuButton extends StatefulWidget {
  VoidCallback onDone;
  VideoContextMenuButton({super.key, required this.onDone});

  @override
  State<VideoContextMenuButton> createState() => _VideoContextMenuButtonState();
}

class _VideoContextMenuButtonState extends State<VideoContextMenuButton> {
  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
          child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 200),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.edit_document),
              title: Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoFormScreen(),
                  ),
                );
              },
            ),
            ListTile(
              textColor: Colors.red,
              iconColor: Colors.red,
              leading: Icon(Icons.delete_forever),
              title: Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                context.read<VideoProvider>().deleteWithConfirm(
                      context,
                      video: context.read<VideoProvider>().getCurrentVideo!,
                      onDoned: widget.onDone,
                    );
              },
            ),
          ],
        ),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _showMenu,
      icon: Icon(Icons.more_vert),
    );
  }
}
