//
//  FlutterAlphaViewPlugin.swift
//  flutter_alpha_player_plugin
//
//  Created by ZhgSignorino on 2023/4/26.
//

import Flutter
import UIKit

class FlutterAlphaViewPlugin: NSObject, FlutterPlatformView, FlutterAlphaPlayerCallBackActionDelegate {
    /// 通信通道
    var _methodChannel: FlutterMethodChannel?
    /// 传进来的坐标
    private var _frame: CGRect?
    /// flutter 传的参数
    private var _arguments: Any?
    /// 交互注册对象
    private var _pluginRegistrar: FlutterPluginRegistrar?

    /// 自定义初始化方法
    init(frame: CGRect, viewIdentifier: Int64, arguments: Any, pluginRegistrar: FlutterPluginRegistrar) {
        super.init()
        _frame = frame
        _arguments = arguments
        _pluginRegistrar = pluginRegistrar
        /// 建立通信通道 用来 监听Flutter 的调用和 调用Fluttter 方法 这里的名称要和Flutter 端保持一致
        _methodChannel = FlutterMethodChannel(name: "flutter_alpha_player_plugin_\(viewIdentifier)", binaryMessenger: pluginRegistrar.messenger())
        _methodChannel?.setMethodCallHandler(handleMethod)
    }

    func view() -> UIView {
        playerNativeView.frame = _frame!
        playerNativeView.clipsToBounds = true
        return playerNativeView
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

            let scaleType = params["scaleType"] as? Int
            playerNativeView.play(path: path, scaleType: scaleType)
            result(0)
            break
        /// 停止播放
        case "stop": fallthrough
        case "release":
            playerNativeView.playerStopWithFinishPlayingCallback()
            result(0)
            break
        /// 同步视图
        case "attachView":
            playerNativeView.addAlphaPlayerViewToParentView()
            result(0)
            break
        /// 移除视图
        case "detachView":
            playerNativeView.removeAlphaPlayerViewFromSuperView()
            result(0)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }

    // MARK: - ios ---> flutter 事件回调

    // @param method 方法名称，唯一关系绑定，
    // @param arguments 参数或者数据 目前默认json字符串
    private func _iosCallFlutterMethodWithParams(method: String, arguments: Any?) {
        _methodChannel?.invokeMethod(method, arguments: arguments)
    }

    // MARK: - NG_AlphaPlayerCallBackActionDelegate

    /// 开始播放
    func alphaPlayerStartPlay() {
        _iosCallFlutterMethodWithParams(method: "play", arguments: nil)
    }

    /// 播放结束回调 isNormalFinsh 是否正常播放结束 （True 是  false 播放报错）
    func alphaPlayerDidFinishPlaying(isNormalFinsh: Bool, errorStr: String?) {
        _iosCallFlutterMethodWithParams(method: "stop", arguments: nil)
    }

    /// 回调每一帧的持续时间
    func videoFrameCallBack(duration: TimeInterval) {
    }

    /// 错误回调
    func errorAction(code: Int, message: String) {
        _iosCallFlutterMethodWithParams(method: "error", arguments: [
            "code": code,
            "message": message,
        ] as [String : Any])
    }

    // MARK: - lazy

    /// 原生视图view
    lazy var playerNativeView: FlutterAlphaPlayerView = {
        let tempNativeView = FlutterAlphaPlayerView()
        tempNativeView.delegate = self
        return tempNativeView
    }()
}
