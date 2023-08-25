import Flutter
import UIKit

class NativeAlphaPlayer: NSObject, FlutterPlatformView, PlayerViewDelegate {
    /// 通信通道
    private var methodChannel: FlutterMethodChannel?
    /// 传进来的坐标
    private var frame: CGRect?
    /// flutter 传的参数
    private var arguments: Any?
    
    /// 原生视图view
    lazy var playerView: PlayerView = {
        let v = PlayerView()
        v.delegate = self
        return v
    }()

    /// 自定义初始化方法
    init(frame: CGRect, viewIdentifier: Int64, arguments: Any, messenger: FlutterBinaryMessenger) {
        super.init()
        self.frame = frame
        self.arguments = arguments
        /// 建立通信通道 用来 监听Flutter 的调用和 调用Fluttter 方法 这里的名称要和Flutter 端保持一致
        methodChannel = FlutterMethodChannel(name: "flutter_alpha_player_plugin_\(viewIdentifier)", binaryMessenger: messenger)
        methodChannel?.setMethodCallHandler {
            [weak self] (call: FlutterMethodCall, result: FlutterResult) in
            // 注意闭包引用 内存无法释放
            self?.handleMethod(call: call, result: result)
        }
    }

    func view() -> UIView {
        playerView.frame = frame!
        playerView.clipsToBounds = true
        return playerView
    }

    // MARK: - flutter 调 ios 回调

    /// 接收flutter发来的消息
    func handleMethod(call: FlutterMethodCall, result: FlutterResult) {
        switch call.method {
        /// 开始播放
        case "play":
            guard let params = call.arguments as? [String: Any],
                  let path = params["filePath"] as? String,
                  !path.isEmpty else {
                errorAction(code: 1001, message: "filePath is empty or null.")
                result(0)
                return
            }

            playerView.addAlphaPlayerViewToParentView()
            let scaleType = params["scaleType"] as? Int
            playerView.play(path: path, scaleType: scaleType)
            result(0)
            break
        /// 停止播放
        case "stop": fallthrough
        case "release":
            playerView.playerStopWithFinishPlayingCallback()
            playerView.removeAlphaPlayerViewFromSuperView()
            result(0)
            break
        /// 同步视图
        case "attachView":
            playerView.addAlphaPlayerViewToParentView()
            result(0)
            break
        /// 移除视图
        case "detachView":
            playerView.removeAlphaPlayerViewFromSuperView()
            result(0)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }

    // MARK: - ios ---> flutter 事件回调

    // @param method 方法名称，唯一关系绑定，
    // @param arguments 参数或者数据
    private func callFlutterMethod(method: String, arguments: Any?) {
        methodChannel?.invokeMethod(method, arguments: arguments)
    }

    // MARK: - PlayerViewDelegate

    /// 开始播放
    func alphaPlayerStartPlay() {
        callFlutterMethod(method: "play", arguments: nil)
    }

    /// 播放结束回调 isNormalFinsh 是否正常播放结束 （True 是  false 播放报错）
    func alphaPlayerDidFinishPlaying(isNormalFinsh: Bool, errorStr: String?) {
        callFlutterMethod(method: "stop", arguments: nil)
    }

    /// 回调每一帧的持续时间
    func videoFrameCallBack(duration: TimeInterval) {
    }

    /// 错误回调
    func errorAction(code: Int, message: String) {
        callFlutterMethod(method: "error", arguments: [
            "code": code,
            "message": message,
        ] as [String : Any])
    }

    deinit {
        print("--- NativeAlphaPlayer deinit ---")
    }
}
