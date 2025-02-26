import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:video_collection/app/components/index.dart';
import 'package:video_collection/app/extensions/string_extension.dart';
import 'package:video_collection/app/models/index.dart';
import 'package:video_collection/app/notifiers/app_notifier.dart';
import 'package:video_collection/app/services/index.dart';
import 'package:video_collection/app/utils/index.dart';
import 'package:video_collection/app/widgets/index.dart';

class VideoScannerScreen extends StatefulWidget {
  void Function(List<String> selectedPath) onChoosed;
  VideoScannerScreen({super.key, required this.onChoosed});

  @override
  State<VideoScannerScreen> createState() => _VideoScannerScreenState();
}

class _VideoScannerScreenState extends State<VideoScannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  List<VideoScannerModel> list = [];
  List<String> choosedList = [];
  bool isLoading = true;
  bool isSelectedAll = false;

  Future<void> init() async {
    try {
      if (!await ThanPkg.platform.isStoragePermissionGranted()) {
        await ThanPkg.platform.requestStoragePermission();
        return;
      }
      setState(() {
        isLoading = true;
      });

      final res = await FileScannerService.instance.getList();

      //gen cover
      await ThanPkg.platform.genVideoCover(
        outDirPath: getCachePath(),
        videoPathList: res,
      );
      setState(() {
        list = res.map((path) => VideoScannerModel.fromPath(path)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showDialogMessage(context, e.toString());
    }
  }

  void _chooseListener() {
    final resList = list.where((vf) => vf.isSelected).toList();
    setState(() {
      choosedList = resList.map((vf) => vf.path).toList();
    });
  }

  void _selectedAll(bool isSelected) {
    final resList = list.map((vf) {
      vf.isSelected = isSelected;
      return vf;
    }).toList();
    setState(() {
      list = resList;
    });
    _chooseListener();
  }

  Widget _getWidget() {
    if (isLoading) {
      return Center(child: TLoader());
    }
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Video File ရှာမတွေ့ပါ!'),
            IconButton(
              color: Colors.blue,
              iconSize: 30,
              onPressed: init,
              icon: Icon(Icons.refresh),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        await init();
      },
      child: GridView.builder(
        itemCount: list.length,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisExtent: 180,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        itemBuilder: (context, index) {
          final video = list[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                list[index].isSelected = !list[index].isSelected;
              });
              _chooseListener();
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 800),
                decoration:
                    BoxDecoration(color: const Color.fromARGB(139, 94, 94, 94)),
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
                        color: isDarkThemeNotifier.value
                            ? Colors.black
                            : const Color.fromARGB(220, 204, 204, 204),
                        child: Text(
                          video.name,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
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
                        onChanged: (value) {
                          list[index].isSelected = value!;
                          _chooseListener();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      contentPadding: 2,
      appBar: AppBar(
        title: Text('Video Scanner'),
        actions: [
          Text(isSelectedAll ? 'UnSelect' : 'Select All'),
          Checkbox(
            // title: Text(isSelectedAll ? 'UnSelect' : 'Selecte'),
            value: isSelectedAll,
            onChanged: (value) {
              setState(() {
                isSelectedAll = value!;
              });
              _selectedAll(isSelectedAll);
            },
          ),
        ],
      ),
      body: _getWidget(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 10,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: choosedList.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                      widget.onChoosed(choosedList);
                    },
              child: Text('Choose ${choosedList.length}'),
            ),
          ],
        ),
      ),
    );
  }
}
