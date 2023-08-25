import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef Callback = void Function();
typedef ErrorCallback = void Function(int code, String error);

// 透明视频播放器控制器
class AlphaPlayerController extends ChangeNotifier {
  String? filePath;
  AlphaPlayerScaleType? scaleType;

  AlphaPlayerEvent? event;

  // view创建完成
  PlatformViewCreatedCallback? onViewCreated;
  // 播放开始的回调
  Callback? onPlay;
  // 播放完成的回调
  Callback? onStop;
  // 播放错误的回调
  ErrorCallback? onError;
  // widget组件dispose的回调
  Callback? onDispose;

  AlphaPlayerController({
    this.onViewCreated,
    this.onPlay,
    this.onStop,
    this.onError,
    this.onDispose,
  });

  /// 播放视频
  /// [filePath] 视频路径
  /// [scaleType] 视频对齐方式
  void play(String filePath, {AlphaPlayerScaleType? scaleType}) {
    this.filePath = filePath;
    this.scaleType = scaleType;

    event = AlphaPlayerEvent.play;
    notifyListeners();
  }

  /// 停止播放
  void stop() {
    event = AlphaPlayerEvent.stop;
    notifyListeners();
  }

  /// 释放
  void release() {
    event = AlphaPlayerEvent.release;
    notifyListeners();
  }
}

enum AlphaPlayerEvent {
  // 播放
  play,
  // 停止
  stop,
  // 释放 ios等同于stop，android释放后无法再播放
  release,
}

/// 视频对齐方式
enum AlphaPlayerScaleType {
  // 拉伸铺满全屏
  scaleToFill,
  // 等比例缩放对齐全屏，居中，屏幕多余留空
  scaleAspectFitCenter,
  // 等比例缩放铺满全屏，裁剪视频多余部分
  scaleAspectFill,
  // 等比例缩放铺满全屏，顶部对齐
  topFill,
  // 等比例缩放铺满全屏，底部对齐
  bottomFill,
  // 等比例缩放铺满全屏，左边对齐
  leftFill,
  // 等比例缩放铺满全屏，右边对齐
  rightFill,
  // 等比例缩放至屏幕宽度，顶部对齐，底部留空
  topFit,
  // 等比例缩放至屏幕宽度，底部对齐，顶部留空
  bottomFit,
  // 等比例缩放至屏幕高度，左边对齐，右边留空
  leftFit,
  // 等比例缩放至屏幕高度，右边对齐，左边留空
  rightFit;

  int get value {
    switch (this) {
      case AlphaPlayerScaleType.scaleToFill:
        return 0;
      case AlphaPlayerScaleType.scaleAspectFitCenter:
        return 1;
      case AlphaPlayerScaleType.scaleAspectFill:
        return 2;
      case AlphaPlayerScaleType.topFill:
        return 3;
      case AlphaPlayerScaleType.bottomFill:
        return 4;
      case AlphaPlayerScaleType.leftFill:
        return 5;
      case AlphaPlayerScaleType.rightFill:
        return 6;
      case AlphaPlayerScaleType.topFit:
        return 7;
      case AlphaPlayerScaleType.bottomFit:
        return 8;
      case AlphaPlayerScaleType.leftFit:
        return 9;
      case AlphaPlayerScaleType.rightFit:
        return 10;
    }
  }
}
