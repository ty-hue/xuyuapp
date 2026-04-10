package com.example.pixelfree_camera

import android.app.Activity
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import java.io.File
import java.util.concurrent.atomic.AtomicBoolean
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class PixelfreeCameraPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private val channelName = "com.pixelfree.camera"
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var textureRegistry: io.flutter.view.TextureRegistry
    private var cameraEngine: CameraXEngine? = null
    private var activity: Activity? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    private var beautySettings: Map<String, Any?> = emptyMap()
    private var filterSettings: Map<String, Any?> = emptyMap()
    private var currentArEffect: String = "none"
    private var enableAudio: Boolean = true

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        textureRegistry = binding.textureRegistry
        channel = MethodChannel(binding.binaryMessenger, channelName)
        channel.setMethodCallHandler(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            when (call.method) {
                "getPlatformVersion" -> result.success("Android ${Build.VERSION.RELEASE}")
                "initCamera" -> {
                    val ratio = call.argument<String>("ratio") ?: "9:16"
                    val flashMode = call.argument<String>("flashMode") ?: "off"
                    val cameraId = call.argument<Int>("cameraId") ?: 0
                    enableAudio = call.argument<Boolean>("enableAudio") ?: true
                    fun argDouble(key: String): Double? {
                        val v = call.argument<Any>(key) ?: return null
                        return when (v) {
                            is Double -> v
                            is Float -> v.toDouble()
                            is Int -> v.toDouble()
                            is Long -> v.toDouble()
                            else -> null
                        }
                    }
                    val previewViewportWidth = argDouble("previewViewportWidth")
                    val previewViewportHeight = argDouble("previewViewportHeight")
                    val enableScreenFlashForFront = call.argument<Boolean>("enableScreenFlashForFront") ?: true
                    val gifMaxDurationMs = call.argument<Int>("gifMaxDurationMs") ?: 5000
                    val recordSpeedProfile = call.argument<String>("recordSpeedProfile") ?: "normal"
                    cameraEngine?.releaseCamera()
                    cameraEngine = CameraXEngine(
                        context,
                        textureRegistry,
                        activityProvider = { activity },
                        onFaceOverlay = { overlay ->
                            runCatching { channel.invokeMethod("onFaceOverlay", overlay) }
                        },
                        onFrontFlashHint = { active, intensity ->
                            mainHandler.post {
                                runCatching {
                                    channel.invokeMethod(
                                        "onFrontFlashHint",
                                        mapOf("active" to active, "intensity" to intensity),
                                    )
                                }
                            }
                        },
                    ).also {
                        it.setBeautySettings(beautySettings)
                        it.setFilterSettings(filterSettings)
                        it.setArEffect(currentArEffect)
                    }
                    val textureId = cameraEngine!!.initCamera(
                        ratio,
                        flashMode,
                        cameraId,
                        enableAudio,
                        previewViewportWidth,
                        previewViewportHeight,
                        enableScreenFlashForFront,
                        gifMaxDurationMs,
                        recordSpeedProfile,
                    )
                    result.success(textureId)
                }
                "getPreviewBufferSize" -> {
                    result.success(cameraEngine?.getPreviewBufferSize())
                }
                "getInputGlTextureId" -> {
                    result.success(cameraEngine?.getInputGlTextureId() ?: -1)
                }
                "setRatio" -> {
                    val ratio = call.argument<String>("ratio") ?: "9:16"
                    cameraEngine?.setRatio(ratio)
                    result.success(null)
                }
                "setFlashMode" -> {
                    val mode = call.argument<String>("mode") ?: "off"
                    cameraEngine?.setFlashMode(mode)
                    result.success(null)
                }
                "flipCamera" -> {
                    cameraEngine?.flipCamera()
                    result.success(null)
                }
                "setBeauty" -> {
                    @Suppress("UNCHECKED_CAST")
                    beautySettings = call.arguments as? Map<String, Any?> ?: emptyMap()
                    cameraEngine?.setBeautySettings(beautySettings)
                    result.success(null)
                }
                "setFilter" -> {
                    @Suppress("UNCHECKED_CAST")
                    filterSettings = call.arguments as? Map<String, Any?> ?: emptyMap()
                    cameraEngine?.setFilterSettings(filterSettings)
                    result.success(null)
                }
                "setSticker" -> {
                    // Legacy sticker API — now a no-op. Stickers move to Flutter post-capture editor.
                    result.success(null)
                }
                "setArEffect" -> {
                    currentArEffect = call.argument<String>("effect") ?: "none"
                    cameraEngine?.setArEffect(currentArEffect)
                    result.success(null)
                }
                "setRecordSpeedProfile" -> {
                    val name = call.argument<String>("profile") ?: "normal"
                    cameraEngine?.setRecordSpeedProfile(name)
                    result.success(null)
                }
                "captureGifFrames" -> {
                    val durationMs = call.argument<Int>("durationMs") ?: 3000
                    val fps = call.argument<Int>("fps") ?: 10
                    val eng = cameraEngine
                    if (eng == null) {
                        result.success("")
                    } else {
                        eng.captureGifFramesToDir(durationMs, fps) { path ->
                            mainHandler.post { result.success(path) }
                        }
                    }
                }
                "getFaceOverlay" -> {
                    result.success(cameraEngine?.getFaceOverlay())
                }
                "getFaceAlignmentDebug" -> {
                    result.success(cameraEngine?.getFaceAlignmentDebug())
                }
                "takePhoto" -> {
                    val eng = cameraEngine
                    if (eng == null) {
                        result.success(mapOf("path" to "", "pixelWidth" to 0, "pixelHeight" to 0))
                    } else {
                        val replied = AtomicBoolean(false)
                        eng.takePhoto { path, pixelW, pixelH ->
                            mainHandler.post {
                                if (replied.compareAndSet(false, true)) {
                                    val jpegBytes: ByteArray? =
                                        path.takeIf { it.isNotEmpty() }?.let { p ->
                                            runCatching {
                                                val f = File(p)
                                                val b = f.readBytes()
                                                f.delete()
                                                b
                                            }.getOrNull()
                                        }
                                    val out = mutableMapOf<String, Any>(
                                        "path" to "",
                                        "pixelWidth" to pixelW,
                                        "pixelHeight" to pixelH,
                                    )
                                    if (jpegBytes != null && jpegBytes.isNotEmpty()) {
                                        out["jpegBytes"] = jpegBytes
                                    }
                                    result.success(out)
                                }
                            }
                        }
                    }
                }
                "startRecord" -> {
                    val recordAudio = call.argument<Boolean>("enableAudio") ?: true
                    cameraEngine?.startRecord(recordAudio)
                    result.success(null)
                }
                "stopRecord" -> {
                    result.success(cameraEngine?.stopRecord() ?: "")
                }
                "releaseCamera" -> {
                    cameraEngine?.releaseCamera()
                    cameraEngine = null
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        cameraEngine?.releaseCamera()
        cameraEngine = null
    }
}
