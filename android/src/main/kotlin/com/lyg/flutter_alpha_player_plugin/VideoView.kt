package com.lyg.flutter_alpha_player_plugin

import android.annotation.SuppressLint
import android.content.Context
import android.text.TextUtils
import android.util.AttributeSet
import android.util.Log
import android.widget.FrameLayout
import android.widget.RelativeLayout
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import com.ss.ugc.android.alpha_player.IMonitor
import com.ss.ugc.android.alpha_player.IPlayerAction
import com.ss.ugc.android.alpha_player.controller.IPlayerController
import com.ss.ugc.android.alpha_player.controller.PlayerController
import com.ss.ugc.android.alpha_player.model.AlphaVideoViewType
import com.ss.ugc.android.alpha_player.model.Configuration
import com.ss.ugc.android.alpha_player.model.DataSource
import com.ss.ugc.android.alpha_player.player.DefaultSystemPlayer
import java.io.File

/**
 * 视频动画展示界面
 */
@SuppressLint("ResourceType")
class VideoView : FrameLayout, LifecycleOwner {

    constructor(context: Context) : super(context)

    constructor(context: Context, attributeSet: AttributeSet?) : super(context, attributeSet)

    constructor(context: Context, attributeSet: AttributeSet? = null, defStyleAttr: Int = 0) : super(context, attributeSet, defStyleAttr)

    companion object {
        const val TAG = "VideoView"
    }

    private var mVideoContainer: RelativeLayout
    private val mRegistry = LifecycleRegistry(this)
    private lateinit var mPlayerController: IPlayerController
    private var isAttach = false

    init {
        //创建一个空的布局
        mVideoContainer = RelativeLayout(context)
        mVideoContainer.layoutParams = RelativeLayout.LayoutParams(
                android.view.ViewGroup.LayoutParams.MATCH_PARENT,
                android.view.ViewGroup.LayoutParams.MATCH_PARENT)
        removeAllViews()
        addView(mVideoContainer)
    }

    //初始化播放器的控制器
    fun initPlayerController(
            context: Context,
            playerAction: IPlayerAction,
            monitor: IMonitor
    ) {
        val configuration = Configuration(context, this)
        // 支持GLSurfaceView&GLTextureView, 默认使用GLSurfaceView
        configuration.alphaVideoViewType = AlphaVideoViewType.GL_TEXTURE_VIEW
        //也可以设置自行实现的Player, demo中提供了基于ExoPlayer的实现
        mPlayerController = PlayerController.get(configuration, DefaultSystemPlayer())
        mPlayerController.setPlayerAction(playerAction)
        mPlayerController.setMonitor(monitor)
    }

    /**
     * 开始播放
     *
     * @param filePath 文件路径
     * @param portraitScaleType 设置竖向参数 2
     * @param landscapeScaleType 设置横向参数 8
     */
    fun start(filePath: String?, portraitScaleType: Int = 2, landscapeScaleType: Int = 8, isLooping: Boolean? = false) {
        if (TextUtils.isEmpty(filePath)) {
            val message = "filePath is empty or null."
            Log.e(TAG, message)
            mPlayerController.getPlayerAction()?.errorAction(1001, message)
            return
        }
        val file = File(filePath)
        // 分割成文件名和文件路径
        val dir = file.parent
        val name = file.name

        //数据转化，合成播放视频，透明的数据源
        val dataSource = DataSource()
                .setBaseDir(dir)
                .setPortraitPath(name, portraitScaleType)
                .setLandscapePath(name, landscapeScaleType)
                .setLooping(isLooping!!)//是否循环
        startDataSource(dataSource)
    }

    //展示画面
    private fun startDataSource(dataSource: DataSource) {
        if (!dataSource.isValid()) {
            Log.e(TAG, "startDataSource: dataSource is invalid.")
        }
        attachView()
        mPlayerController.start(dataSource)
    }

    //同步窗体,动画站位布局填充到window
    fun attachView() {
        if (!isAttach) {
            isAttach = true
            mPlayerController.attachAlphaView(mVideoContainer)
        }

    }

    //移除动画窗体
    fun detachView() {
        isAttach = false
        mPlayerController.detachAlphaView(mVideoContainer)
    }

    //释放动画相关资源
    fun releasePlayerController() {
        mPlayerController.let {
            it.detachAlphaView(mVideoContainer)
            it.release()
        }
    }

    fun stop() {
        mPlayerController.stop()
        detachView()
    }

    // reset 能释放内存
    fun reset() {
        mPlayerController.reset()
    }

    override fun getLifecycle(): Lifecycle {
        return mRegistry
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        mRegistry.currentState = Lifecycle.State.CREATED
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        mRegistry.currentState = Lifecycle.State.DESTROYED
    }

    override fun onWindowVisibilityChanged(visibility: Int) {
        super.onWindowVisibilityChanged(visibility)
        if (visibility == VISIBLE) {
            mRegistry.handleLifecycleEvent(Lifecycle.Event.ON_START)
            mRegistry.handleLifecycleEvent(Lifecycle.Event.ON_RESUME)
        } else if (visibility == GONE || visibility == INVISIBLE) {
            mRegistry.handleLifecycleEvent(Lifecycle.Event.ON_PAUSE)
            mRegistry.handleLifecycleEvent(Lifecycle.Event.ON_STOP)
        }

    }
}

