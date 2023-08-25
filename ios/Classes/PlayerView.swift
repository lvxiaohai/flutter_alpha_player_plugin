import UIKit

/// 回调事件
protocol PlayerViewDelegate: AnyObject {
    /// 开始播放
    func alphaPlayerStartPlay()

    /// 播放结束回调 isNormalFinsh 是否正常播放结束 （True 是  false 播放报错）
    func alphaPlayerDidFinishPlaying(isNormalFinsh: Bool, errorStr: String?)

    /// 回调每一帧的持续时间
    func videoFrameCallBack(duration: TimeInterval)
    
    /// 错误回调
    func errorAction(code: Int, message: String)
}

/// 播放器
class PlayerView: UIView, BDAlphaPlayerMetalViewDelegate {
    /// 代理
    weak var delegate: PlayerViewDelegate?

    /// 播放器视图
    var metalView: BDAlphaPlayerMetalView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func initViews() {
        isHidden = true
        initMetalView()
    }

    /// 初始化播放器视图
    private func initMetalView() {
        if metalView == nil {
            metalView = BDAlphaPlayerMetalView(delegate: self)
            addSubview(metalView!)
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

    /// 开始播放
    // @param path 文件路径
    // @param scaleType 缩放模式
    func play(path: String, scaleType: Int?) {
        if metalView == nil {
            initMetalView()
        }

        isHidden = false
        delegate?.alphaPlayerStartPlay()
        let mode = BDAlphaPlayerContentMode(rawValue: UInt(scaleType ?? 2)) ?? .scaleAspectFill
        startPlay(path: path, contentMode: mode)
    }

    /// 停止播放 -- 停止显示而不调用didFinishPlayingWithError方法，不会触发停止回调
    func stopAlphaPlayer() {
        metalView?.stop()
    }

    /// 通过调用didFinishPlayingWithError方法停止显示，会触发停止回调
    func playerStopWithFinishPlayingCallback() {
        metalView?.stopWithFinishPlayingCallback()
    }

    /// 从父视图移除播放视图
    func removeAlphaPlayerViewFromSuperView() {
        metalView?.removeFromSuperview()
        metalView = nil
    }

    /// 添加播放视图到父视图
    func addAlphaPlayerViewToParentView() {
        if metalView != nil {
            metalView?.removeFromSuperview()
            addSubview(metalView!)
        } else {
            initMetalView()
        }
    }

    /// 当前播放的Mp4视频播放时长
    func totalDurationOfPlayingVideo() -> TimeInterval {
        if metalView != nil {
            return metalView?.totalDurationOfPlayingEffect() ?? 0
        }
        return 0
    }

    /// 播放器状态 （0 停止 1 播放）
    func currentVideoPlayState() -> Int {
        if metalView?.state == BDAlphaPlayerPlayState.play {
            return 1
        } else {
            return 0
        }
    }

    /// Resource model for MP4.
    func playerResourceModel() -> BDAlphaPlayerResourceModel? {
        return metalView?.model
    }

    // MARK: - private

    /// 开始播放
    private func startPlay(path: String, contentMode: BDAlphaPlayerContentMode) {
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
        metalView?.play(with: config, andResourceModel: model)
    }

    /// 释放播放器
    deinit {
        playerStopWithFinishPlayingCallback()
        removeAlphaPlayerViewFromSuperView()
        print("--- PlayerView deinit ---")
    }
}
