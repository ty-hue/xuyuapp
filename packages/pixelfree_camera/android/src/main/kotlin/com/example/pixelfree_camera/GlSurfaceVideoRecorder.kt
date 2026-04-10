package com.example.pixelfree_camera

import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer
import android.view.Surface
import java.io.File

/**
 * H.264 encoder fed by OpenGL rendering into [MediaCodec.createInputSurface].
 *
 * @param orientationHintDegrees 与 [MediaRecorder.setOrientationHint] 相同，使播放器/相册将传感器横向像素尺寸按竖屏持机正确显示（与 GL 预览一致）。
 */
internal class GlSurfaceVideoRecorder(
    private val outputFile: File,
    private val width: Int,
    private val height: Int,
    private val frameRate: Int = 30,
    orientationHintDegrees: Int = 0,
) {
    private val codec = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC)
    private val bufferInfo = MediaCodec.BufferInfo()
    private val muxer = MediaMuxer(outputFile.absolutePath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4).also { m ->
        m.setOrientationHint(MediaMuxerHelper.normalizeMp4OrientationHint(orientationHintDegrees))
    }
    private var inputSurface: Surface? = null
    private var trackIndex = -1
    private var muxerStarted = false
    private var started = false

    fun start(): Surface {
        val format = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, width, height).apply {
            setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface)
            setInteger(MediaFormat.KEY_BIT_RATE, (width * height * 6).coerceAtLeast(2_000_000))
            setInteger(MediaFormat.KEY_FRAME_RATE, frameRate)
            setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 2)
        }
        codec.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
        inputSurface = codec.createInputSurface()
        codec.start()
        started = true
        return inputSurface!!
    }

    fun drainOutput() {
        if (!started) return
        while (true) {
            val outputIndex = codec.dequeueOutputBuffer(bufferInfo, 0)
            when {
                outputIndex == MediaCodec.INFO_TRY_AGAIN_LATER -> return
                outputIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                    if (!muxerStarted) {
                        trackIndex = muxer.addTrack(codec.outputFormat)
                        muxer.start()
                        muxerStarted = true
                    }
                }
                outputIndex >= 0 -> {
                    val outputBuffer = codec.getOutputBuffer(outputIndex)
                    if (outputBuffer != null) {
                        if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0) {
                            bufferInfo.size = 0
                        }
                        if (bufferInfo.size > 0 && muxerStarted) {
                            outputBuffer.position(bufferInfo.offset)
                            outputBuffer.limit(bufferInfo.offset + bufferInfo.size)
                            muxer.writeSampleData(trackIndex, outputBuffer, bufferInfo)
                        }
                    }
                    codec.releaseOutputBuffer(outputIndex, false)
                    if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                        return
                    }
                }
            }
        }
    }

    /** Call after GL stops submitting frames (encoder surface can be destroyed). */
    fun finishEncoding() {
        if (!started) return
        runCatching { codec.signalEndOfInputStream() }
        while (true) {
            val outputIndex = codec.dequeueOutputBuffer(bufferInfo, 10_000)
            when {
                outputIndex == MediaCodec.INFO_TRY_AGAIN_LATER -> continue
                outputIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                    if (!muxerStarted) {
                        trackIndex = muxer.addTrack(codec.outputFormat)
                        muxer.start()
                        muxerStarted = true
                    }
                }
                outputIndex >= 0 -> {
                    val outputBuffer = codec.getOutputBuffer(outputIndex)
                    if (outputBuffer != null) {
                        if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0) {
                            bufferInfo.size = 0
                        }
                        if (bufferInfo.size > 0 && muxerStarted) {
                            outputBuffer.position(bufferInfo.offset)
                            outputBuffer.limit(bufferInfo.offset + bufferInfo.size)
                            muxer.writeSampleData(trackIndex, outputBuffer, bufferInfo)
                        }
                    }
                    codec.releaseOutputBuffer(outputIndex, false)
                    if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                        break
                    }
                }
                else -> break
            }
        }
        started = false
        runCatching { codec.stop() }
        runCatching { codec.release() }
        inputSurface = null
        if (muxerStarted) {
            runCatching { muxer.stop() }
        }
        runCatching { muxer.release() }
    }
}
