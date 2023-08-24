import 'package:flutter/material.dart';
import 'package:flutter_alpha_player_plugin/alpha_player_controller.dart';
import 'package:flutter_alpha_player_plugin/alpha_player_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> downloadPathList = [];
  bool isDownload = false;
  final ImagePicker _picker = ImagePicker();
  String? videoPath;
  AlphaPlayerController controller = AlphaPlayerController(
    onViewCreated: (id) {
      print("==== onCreated $id");
    },
    onPlay: () {
      print("==== onPlay");
    },
    onStop: () {
      print("==== onStop");
    },
    onError: (code, error) {
      print("==== onError $code $error");
    },
  );
  AlphaPlayerController controller2 = AlphaPlayerController(
    onViewCreated: (id) {
      print("==== onCreated2 $id");
    },
    onPlay: () {
      print("==== onPlay2");
    },
    onStop: () {
      print("==== onStop2");
    },
    onError: (code, error) {
      print("==== onError2 $code $error");
    },
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 100),
                    child: SizedBox(
                      child: Text(
                        "视频路径为：$videoPath",
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        child: const Text("选择"),
                        onPressed: () async {
                          final XFile? video = await _picker.pickVideo(
                              source: ImageSource.gallery);
                          if (video == null) {
                            return;
                          }
                          videoPath = video.path;
                          setState(() {});
                        },
                      ),
                      ElevatedButton(
                        child: const Text("播放"),
                        onPressed: () async {
                          if (videoPath != null) {
                            controller.play(videoPath!,
                                scaleType: AlphaPlayerScaleType.bottomFill);
                            controller2.play(videoPath!,
                                scaleType: AlphaPlayerScaleType.topFill);
                          }
                        },
                      ),
                      ElevatedButton(
                        child: const Text("停止1"),
                        onPressed: () async {
                          controller.stop();
                        },
                      ),
                      ElevatedButton(
                        child: const Text("释放1"),
                        onPressed: () async {
                          controller.release();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 300,
                left: 0,
                child: IgnorePointer(
                  child: Container(
                    // clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1,
                            color: Colors.amberAccent,
                            strokeAlign: BorderSide.strokeAlignOutside)),
                    width: 300,
                    height: 300,
                    child: AlphaPlayerView(
                      controller: controller,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 300,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    // clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1,
                            color: Colors.amberAccent,
                            strokeAlign: BorderSide.strokeAlignOutside)),
                    width: 150,
                    height: 200,
                    child: AlphaPlayerView(
                      controller: controller2,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 300,
                left: 150,
                child: Container(
                  color: const Color.fromRGBO(0, 0, 0, 0.1),
                  width: 100,
                  height: 100,
                  child: const Text("测试层级"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
