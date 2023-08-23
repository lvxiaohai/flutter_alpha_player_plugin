//
//  FlutterAlphaPlayerPluginFactory.swift
//  AlphaPlayer
//
//  Created by ZhgSignorino on 2023/4/26.
//

import Flutter
import UIKit
class FlutterAlphaPlayerPluginFactory: NSObject, FlutterPlatformViewFactory {
    /// 注册对象
    var _pluginRegistrar: FlutterPluginRegistrar?

    /// 自定义初始化方法
    init(pluginRegistrar: FlutterPluginRegistrar) {
        super.init()
        _pluginRegistrar = pluginRegistrar
    }

    // MARK: - 实现FlutterPlatformViewFactory 代理方法

    /// 这个方法一定要写，否则接受不到flutter的传参
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    /// FlutterPlatformViewFactory 代理方法 返回过去一个类来布局 原生视图
    /// @param frame frame
    /// @param viewId view的id
    /// @param args 初始化的参数
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return FlutterAlphaViewPlugin(frame: frame, viewIdentifier: viewId, arguments: args as Any, pluginRegistrar: _pluginRegistrar!)
    }
}
