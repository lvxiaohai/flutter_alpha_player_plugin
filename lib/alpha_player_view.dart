import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'alpha_player_controller.dart';

const _viewType = "flutter_alpha_player";
const String _channelName = "flutter_alpha_player_plugin_";

typedef OnPlayCallback = void Function();
typedef OnStopCallback = void Function();

// 透明视频播放器
class AlphaPlayerView extends StatefulWidget {
  final AlphaPlayerController controller;
  // view创建完成
  final PlatformViewCreatedCallback? onViewCreated;
  // 播放开始的回调
  final OnPlayCallback? onPlay;
  // 播放完成的回调
  final OnStopCallback? onStop;

  const AlphaPlayerView(
      {Key? key,
      required this.controller,
      this.onViewCreated,
      this.onPlay,
      this.onStop})
      : super(key: key);

  @override
  State<AlphaPlayerView> createState() => _AlphaPlayerViewState();
}

class _AlphaPlayerViewState extends State<AlphaPlayerView> {
  MethodChannel? methodChannel;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    methodChannel?.setMethodCallHandler(null);
    super.dispose();
  }

  void _onController() {
    switch (widget.controller.event) {
      case AlphaPlayerEvent.play:
        methodChannel?.invokeMethod('play', {
          'filePath': widget.controller.filePath,
          'scaleType': widget.controller.scaleType?.value,
        });
        break;
      case AlphaPlayerEvent.stop:
        methodChannel?.invokeMethod('stop');
        break;
      case AlphaPlayerEvent.release:
        methodChannel?.invokeMethod('release');
        break;
      case null:
        break;
    }
  }

  void _onPlatformViewCreated(int id) {
    methodChannel = MethodChannel('$_channelName$id');
    widget.onViewCreated?.call(id);
    methodChannel?.setMethodCallHandler((call) async {
      switch (call.method) {
        case "play":
          widget.onPlay?.call();
          break;
        case "stop":
          widget.onStop?.call();
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final params = <String, dynamic>{};
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: _viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: _viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return const Text('暂不支持该平台');
  }
}
