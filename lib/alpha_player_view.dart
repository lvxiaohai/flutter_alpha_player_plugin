import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'alpha_player_controller.dart';

const _viewType = "flutter_alpha_player";
const String _channelName = "flutter_alpha_player_plugin_";

// 透明视频播放器
class AlphaPlayerView extends StatefulWidget {
  final AlphaPlayerController controller;

  const AlphaPlayerView({
    Key? key,
    required this.controller,
  }) : super(key: key);

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
    widget.controller.onDispose?.call();
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
    widget.controller.onViewCreated?.call(id);

    methodChannel?.setMethodCallHandler((call) async {
      switch (call.method) {
        case "play":
          widget.controller.onPlay?.call();
          break;
        case "stop":
          widget.controller.onStop?.call();
          break;
        case "error":
          var code = 0;
          var message = "";
          if (call.arguments is Map) {
            code = call.arguments['code'] ?? 0;
            message = call.arguments['message'] ?? "";
          }
          widget.controller.onError?.call(code, message);
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
