package com.lyg.flutter_alpha_player_plugin

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import com.ss.ugc.android.alpha_player.IMonitor
import com.ss.ugc.android.alpha_player.IPlayerAction
import com.ss.ugc.android.alpha_player.model.ScaleType
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

///原生界面需要实现PlatformView
internal class NativeAlphaPlayer(
        binaryMessenger: BinaryMessenger,
        context: Context?,
        id: Int?,
        createParams: Map<String, Any>?) : MethodChannel.MethodCallHandler, PlatformView {

    private var methodResult: MethodChannel.Result? = null
    private val mContext: Context? = context
    private lateinit var alphaPlayer: VideoGiftView
    private lateinit var channel: MethodChannel
    private var handler: Handler = Handler(Looper.getMainLooper())


    init {
        mContext?.let {
            alphaPlayer = VideoGiftView(it)
            alphaPlayer.initPlayerController(it, object : IPlayerAction {
                override fun endAction() {
                    _onFlutterMethodCall("stop", null)
                }

                override fun onVideoSizeChanged(videoWidth: Int, videoHeight: Int, scaleType: ScaleType) {
                    print("videoWidth: $videoWidth videoHeight: $videoHeight scaleType: $scaleType")
                }

                override fun startAction() {
                    _onFlutterMethodCall("play", null)
                }
            }, object : IMonitor {
                override fun monitor(
                        result: Boolean,
                        playType: String,
                        what: Int,
                        extra: Int,
                        errorInfo: String
                ) {
                    print("result: $result playType: $playType what: $what extra: $extra errorInfo: $errorInfo")
                }
            }
            )
            alphaPlayer.attachView()

            channel = MethodChannel(binaryMessenger, "flutter_alpha_player_plugin_${id}")
            channel.setMethodCallHandler(this);
        }
    }

    //MethodChannel 回调 Flutter-》Android
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        methodResult = result
        when (call.method) {
            // 播放视频
            "play" -> {
                val path = call.argument<String>("filePath")
                val scaleType = call.argument<Int?>("scaleType") ?: 2
                alphaPlayer.start(path, scaleType, scaleType, false)
                result.success(0)
            }
            // 停止
            "stop" -> {
                alphaPlayer.stop()
                result.success(0)
            }
            // 释放
            "release" -> {
                alphaPlayer.releasePlayerController()
                result.success(0)
            }
            // 同步视图
            "attachView" -> {
                alphaPlayer.attachView()
                result.success(0)
            }
            // 移除视图
            "detachView" -> {
                alphaPlayer.detachView()
                result.success(0)
            }
        }
    }
    // android -> flutter 
    /**
     * @param method 方法名称，唯一关系绑定，
     * @param arguments 参数或者数据 目前默认json
     */
    private fun _onFlutterMethodCall(method: String, arguments: Any?) {
        handler.post {
            channel.invokeMethod(method, arguments)
        }
    }

    //获取View
    override fun getView(): View? {
        return alphaPlayer;
    }

    //销毁View
    override fun dispose() {
        alphaPlayer.detachView()
        alphaPlayer.releasePlayerController()
    }
}