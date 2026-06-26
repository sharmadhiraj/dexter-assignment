package com.sharmadhiraj.dexter_assignment.service

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder

class AlwaysListeningService : Service() {

    private val sampleRate = 16000
    private val channelConfig = AudioFormat.CHANNEL_IN_MONO
    private val channelCount = 1
    private val audioEncoding = AudioFormat.ENCODING_PCM_16BIT
    private val bitsPerSample = 16
    private val bufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioEncoding)
    private val chunkDurationMs = 10000L
    private val rawAudioFileName = "temp_record.raw"

    private var recorder: AudioRecord? = null
    private var recordingThread: Thread? = null
    @Volatile private var isRecording = false
    private val chunkHandler = Handler(Looper.getMainLooper())

    // region Lifecycle

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        Log.d(TAG, "Service created")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(NOTIFICATION_ID, buildNotification())
        startNewChunk()
        Log.d(TAG, "Service started")
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        finalizeChunk(andStartNext = false)
        Log.d(TAG, "Service destroyed")
    }

    // endregion

    // region Recording cycle

    @SuppressLint("MissingPermission")
    private fun startNewChunk() {
        try {
            recorder = AudioRecord(
                MediaRecorder.AudioSource.MIC, sampleRate, channelConfig, audioEncoding, bufferSize
            )
            if (recorder!!.state != AudioRecord.STATE_INITIALIZED) {
                Log.e(TAG, "AudioRecord failed to initialize — skipping chunk")
                recorder!!.release()
                recorder = null
                return
            }
            recorder!!.startRecording()
            isRecording = true
            recordingThread = Thread(::streamAudioToFile).also { it.start() }
            Log.d(TAG, "Chunk recording started (${chunkDurationMs}ms, ${sampleRate}Hz mono)")
            chunkHandler.postDelayed({ finalizeChunk(andStartNext = true) }, chunkDurationMs)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start recording: $e")
        }
    }

    private fun finalizeChunk(andStartNext: Boolean) {
        val activeRecorder = recorder ?: return
        try {
            isRecording = false
            if (activeRecorder.state == AudioRecord.STATE_INITIALIZED) activeRecorder.stop()
            activeRecorder.release()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to stop recorder: $e")
        } finally {
            recorder = null
            recordingThread = null
        }

        val rawPath = appFilePath(rawAudioFileName)
        val wavPath = appFilePath("final_${System.currentTimeMillis()}.wav")
        convertRawToWav(rawPath, wavPath)
        File(rawPath).delete()
        Log.d(TAG, "WAV saved: ${wavPath.substringAfterLast('/')}")

        if (andStartNext) startNewChunk()
        else chunkHandler.removeCallbacksAndMessages(null)
    }

    // endregion

    // region Audio capture

    private fun streamAudioToFile() {
        val buffer = ByteArray(bufferSize)
        try {
            FileOutputStream(appFilePath(rawAudioFileName)).use { output ->
                while (isRecording) {
                    val bytesRead = recorder!!.read(buffer, 0, bufferSize)
                    if (bytesRead > 0) output.write(buffer, 0, bytesRead)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to stream audio to file: $e")
        }
    }

    // endregion

    // region WAV conversion

    private fun convertRawToWav(rawPath: String, wavPath: String) {
        try {
            FileInputStream(rawPath).use { input ->
                FileOutputStream(wavPath).use { output ->
                    val audioDataLen = input.channel.size()
                    val byteRate = (sampleRate * channelCount * bitsPerSample / 8).toLong()
                    output.write(buildWavHeader(audioDataLen, byteRate))
                    val buffer = ByteArray(bufferSize)
                    var bytesRead: Int
                    while (input.read(buffer).also { bytesRead = it } != -1) {
                        output.write(buffer, 0, bytesRead)
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to convert raw audio to WAV: $e")
        }
    }

    private fun buildWavHeader(audioDataLen: Long, byteRate: Long): ByteArray {
        val blockAlign = (channelCount * bitsPerSample / 8).toShort()
        return ByteBuffer.allocate(WAV_HEADER_SIZE)
            .order(ByteOrder.LITTLE_ENDIAN)
            .put("RIFF".toByteArray(Charsets.US_ASCII))
            .putInt((audioDataLen + 36).toInt())    // RIFF chunk size
            .put("WAVE".toByteArray(Charsets.US_ASCII))
            .put("fmt ".toByteArray(Charsets.US_ASCII))
            .putInt(16)                              // fmt chunk size (PCM)
            .putShort(1)                             // audio format: PCM
            .putShort(channelCount.toShort())
            .putInt(sampleRate)
            .putInt(byteRate.toInt())
            .putShort(blockAlign)
            .putShort(bitsPerSample.toShort())
            .put("data".toByteArray(Charsets.US_ASCII))
            .putInt(audioDataLen.toInt())            // data chunk size
            .array()
    }

    // endregion

    // region Helpers

    private fun buildNotification() = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
        .setContentTitle("Dexter")
        .setContentText("Listening...")
        .setSmallIcon(android.R.drawable.ic_btn_speak_now)
        .build()

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Always Listening",
                NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    private fun appFilePath(fileName: String) = "$filesDir/$fileName"

    // endregion

    companion object {
        private const val TAG = "AlwaysListeningService"
        private const val NOTIFICATION_CHANNEL_ID = "always_listening_channel"
        private const val NOTIFICATION_ID = 1
        private const val WAV_HEADER_SIZE = 44
    }
}
