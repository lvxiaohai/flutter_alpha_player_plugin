//
//  NG_AlphaPlayerView.swift
//  AlphaPlayer
//
//  Created by ZhgSignorino on 2023/4/24.
//

import UIKit

/// 回调事件
protocol FlutterAlphaPlayerCallBackActionDelegate {
    /// 开始播放
    func alphaPlayerStartPlay()

    /// 播放结束回调 isNormalFinsh 是否正常播放结束 （True 是  false 播放报错）
    func alphaPlayerDidFinishPlaying(isNormalFinsh: Bool, errorStr: String?)

    /// 回调每一帧的持续时间
    func videoFrameCallBack(duration: TimeInterval)
}

/// 播放器
class FlutterAlphaPlayerView: UIView, BDAlphaPlayerMetalViewDelegate {
    /// 代理
    var delegate: FlutterAlphaPlayerCallBackActionDelegate?

    /// 播放器视图
    var playerMetalView: BDAlphaPlayerMetalView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        _initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func _initViews() {
        __initMetalView()
    }

    /// 初始化播放器视图
    private func __initMetalView() {
        if playerMetalView == nil {
            playerMetalView = BDAlphaPlayerMetalView(delegate: self)
            addSubview(playerMetalView!)
        }
    }

    // MARK: - BDAlphaPlayerMetalViewDelegate

    /// 播放结束回调
    func metalView(_ metalView: BDAlphaPlayerMetalView, didFinishPlayingWithError error: Error) {
        isHidden = true
        if error == nil {
            delegate?.alphaPlayerDidFinishPlaying(isNormalFinsh: true, errorStr: nil)
        } else {
            delegate?.alphaPlayerDidFinishPlaying(isNormalFinsh: false, errorStr: String(format: "%@", error.localizedDescription))
        }
    }

    /// 回调每一帧的持续时间
    func frameCallBack(_ duration: TimeInterval) {
        delegate?.videoFrameCallBack(duration: duration)
    }

    // MARK: - public

    func play(filePath: String?, playerOrientation: Int) {
        if filePath == nil {
            print("filePath is null")
            return
        }
        if playerMetalView == nil {
            __initMetalView()
        }
    }

    /// 开始播放
    // @param path 文件路径
    // @param scaleType 缩放模式
    func play(path: String, scaleType: Int?) {
        if path.isEmpty {
            print("path is empty")
            return
        }
        if playerMetalView == nil {
            __initMetalView()
        }

        isHidden = false
        delegate?.alphaPlayerStartPlay()
        let mode = BDAlphaPlayerContentMode(rawValue: UInt(scaleType ?? 2)) ?? .scaleAspectFill
        _startPlay(path: path, contentMode: mode)
    }

    /// 停止播放 -- 停止显示而不调用didFinishPlayingWithError方法，不会触发停止回调
    func stopAlphaPlayer() {
        playerMetalView?.stop()
    }

    /// 通过调用didFinishPlayingWithError方法停止显示，会触发停止回调
    func playerStopWithFinishPlayingCallback() {
        playerMetalView?.stopWithFinishPlayingCallback()
    }

    /// 从父视图移除播放视图
    func removeAlphaPlayerViewFromSuperView() {
        playerMetalView?.removeFromSuperview()
        playerMetalView = nil
    }

    /// 添加播放视图到父视图
    func addAlphaPlayerViewToParentView() {
        if playerMetalView != nil {
            playerMetalView?.removeFromSuperview()
            addSubview(playerMetalView!)
        } else {
            __initMetalView()
        }
    }

    /// 当前播放的Mp4视频播放时长
    func totalDurationOfPlayingVideo() -> TimeInterval {
        if playerMetalView != nil {
            return playerMetalView?.totalDurationOfPlayingEffect() ?? 0
        }
        return 0
    }

    /// 播放器状态 （0 停止 1 播放）
    func currentVideoPlayState() -> Int {
        if playerMetalView?.state == BDAlphaPlayerPlayState.play {
            return 1
        } else {
            return 0
        }
    }

    /// Resource model for MP4.
    func playerResourceModel() -> BDAlphaPlayerResourceModel? {
        return playerMetalView?.model
    }

    // MARK: - private

    /// 开始播放
    private func _startPlay(path: String, contentMode: BDAlphaPlayerContentMode) {
        let url = URL(fileURLWithPath: path)
        let dir = url.deletingLastPathComponent().path
        let name = url.lastPathComponent

        let config = BDAlphaPlayerMetalConfiguration.default()
        config.directory = dir
        config.renderSuperViewFrame = frame
        config.orientation = BDAlphaPlayerOrientation.portrait

        let info = BDAlphaPlayerResourceInfo()
        info.resourceFilePath = path
        info.resourceName = name
        info.contentMode = contentMode
        info.resourceFileURL = url

        let model = BDAlphaPlayerResourceModel(orientation: config.orientation, portraitResourceInfo: info, landscapeResourceInfo: info)!
        playerMetalView?.play(with: config, andResourceModel: model)
    }

    /// 释放播放器
    deinit {
        playerStopWithFinishPlayingCallback()
        removeAlphaPlayerViewFromSuperView()
    }
}
