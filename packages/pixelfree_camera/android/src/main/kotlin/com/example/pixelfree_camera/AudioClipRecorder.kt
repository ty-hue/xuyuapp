package com.example.pixelfree_camera

import android.media.MediaRecorder
import java.io.File

internal class AudioClipRecorder(
    private val outputFile: File,
) {
    private var recorder: MediaRecorder? = null

    fun start() {
        recorder = MediaRecorder().apply {
            setAudioSource(MediaRecorder.AudioSource.MIC)
            setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
            setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
            setAudioEncodingBitRate(128000)
            setAudioSamplingRate(44100)
            setOutputFile(outputFile.absolutePath)
            prepare()
            start()
        }
    }

    fun stop() {
        val current = recorder ?: return
        runCatching { current.stop() }
        runCatching { current.release() }
        recorder = null
    }
}
