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
  final ImagePicker _picker = ImagePicker();
  String? videoPath;
  int viewKey = 1;

  AlphaPlayerController controller = AlphaPlayerController(
    onViewCreated: (id) {
      debugPrint("--- onCreated $id");
      // showToast("onCreated $id");
    },
    onPlay: () {
      debugPrint("--- onPlay");
      showToast("onPlay");
    },
    onStop: () {
      debugPrint("--- onStop");
      showToast("onStop");
    },
    onError: (code, error) {
      debugPrint("--- onError $code $error");
      showToast("onError $code $error");
    },
    onDispose: () {
      debugPrint("--- onDispose");
      showToast("onDispose");
    },
  );
  AlphaPlayerController controller2 = AlphaPlayerController(
    onViewCreated: (id) {
      debugPrint("==== onCreated2 $id");
    },
    onPlay: () {
      debugPrint("==== onPlay2");
    },
    onStop: () {
      debugPrint("==== onStop2");
    },
    onError: (code, error) {
      debugPrint("==== onError2 $code $error");
    },
    onDispose: () {
      debugPrint("==== onDispose2");
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
            fit: StackFit.expand,
            children: [
              Positioned(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 60),
                      child: Text(
                        "视频路径为：$videoPath",
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
                            setState(() {
                              videoPath = video.path;
                            });
                          },
                        ),
                        ElevatedButton(
                          child: const Text("播放"),
                          onPressed: () async {
                            if (videoPath != null) {
                              controller.play(videoPath!,
                                  scaleType: AlphaPlayerScaleType.bottomFit);
                              controller2.play(videoPath!,
                                  scaleType: AlphaPlayerScaleType.rightFit);
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
                          child: const Text("切换key1"),
                          onPressed: () async {
                            setState(() {
                              viewKey += 1;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.maxFinite,
                      height: 500,
                      child: Image.asset(
                        'assets/bg.jpg',
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                child: IgnorePointer(
                  child: SizedBox(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    child: viewKey % 10 < 5
                        ? AlphaPlayerView(
                            key: Key("one_$viewKey"),
                            controller: controller,
                          )
                        : Center(
                            child: Text(
                            "当前viewKey: $viewKey",
                            style: const TextStyle(color: Colors.white),
                          )),
                  ),
                ),
              ),
              Positioned(
                top: 350,
                right: 10,
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
                top: 400,
                left: 150,
                child: Container(
                  color: const Color.fromRGBO(0, 255, 0, 0.2),
                  width: 100,
                  height: 100,
                  child: const Center(
                    child: Text(
                      "测试层级",
                      style: TextStyle(color: Colors.white, shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(0, 0),
                          blurRadius: 10,
                        )
                      ]),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
