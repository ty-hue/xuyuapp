package com.example.pixelfree_camera

import android.media.MediaExtractor
import android.media.MediaMuxer
import java.io.File
import java.nio.ByteBuffer

internal object MediaMuxerHelper {
    /** 0..359，与 [MediaMuxer.setOrientationHint] 一致（设备传感器朝向均为 90° 整数倍）。 */
    fun normalizeMp4OrientationHint(degrees: Int): Int = ((degrees % 360) + 360) % 360

    fun mergeVideoAndAudio(
        videoFile: File,
        audioFile: File,
        outputFile: File,
        orientationHintDegrees: Int,
    ) {
        val muxer = MediaMuxer(outputFile.absolutePath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4).also { m ->
            m.setOrientationHint(normalizeMp4OrientationHint(orientationHintDegrees))
        }
        val videoExtractor = MediaExtractor()
        val audioExtractor = MediaExtractor()
        try {
            videoExtractor.setDataSource(videoFile.absolutePath)
            audioExtractor.setDataSource(audioFile.absolutePath)

            val videoTrack = selectTrack(videoExtractor, "video/")
            val audioTrack = selectTrack(audioExtractor, "audio/")
            if (videoTrack < 0 || audioTrack < 0) {
                throw IllegalStateException("Missing audio or video track for muxing")
            }

            videoExtractor.selectTrack(videoTrack)
            audioExtractor.selectTrack(audioTrack)

            val muxerVideoTrack = muxer.addTrack(videoExtractor.getTrackFormat(videoTrack))
            val muxerAudioTrack = muxer.addTrack(audioExtractor.getTrackFormat(audioTrack))
            muxer.start()

            writeSamples(videoExtractor, muxer, muxerVideoTrack)
            writeSamples(audioExtractor, muxer, muxerAudioTrack)
        } finally {
            runCatching { muxer.stop() }
            runCatching { muxer.release() }
            runCatching { videoExtractor.release() }
            runCatching { audioExtractor.release() }
        }
    }

    private fun writeSamples(
        extractor: MediaExtractor,
        muxer: MediaMuxer,
        targetTrack: Int,
    ) {
        val buffer = ByteBuffer.allocate(1024 * 1024)
        val info = android.media.MediaCodec.BufferInfo()
        while (true) {
            info.offset = 0
            info.size = extractor.readSampleData(buffer, 0)
            if (info.size < 0) break
            info.presentationTimeUs = extractor.sampleTime
            info.flags = extractor.sampleFlags
            muxer.writeSampleData(targetTrack, buffer, info)
            extractor.advance()
        }
    }

    private fun selectTrack(extractor: MediaExtractor, prefix: String): Int {
        for (index in 0 until extractor.trackCount) {
            val mime = extractor.getTrackFormat(index).getString("mime") ?: continue
            if (mime.startsWith(prefix)) return index
        }
        return -1
    }
}
