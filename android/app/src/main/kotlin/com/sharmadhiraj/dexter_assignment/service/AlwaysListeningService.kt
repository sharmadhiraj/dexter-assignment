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
import java.io.IOException

class AlwaysListeningService : Service() {

    private var recorder: AudioRecord? = null
    private val sampleRate = 44100
    private val channel = AudioFormat.CHANNEL_IN_STEREO
    private val channelCount = 2
    private val audioEncoding = AudioFormat.ENCODING_PCM_16BIT
    private val bufferSize = AudioRecord.getMinBufferSize(
        44100, AudioFormat.CHANNEL_IN_STEREO, AudioFormat.ENCODING_PCM_16BIT
    )
    private var recordingThread: Thread? = null
    @Volatile
    private var isRecording = false
    private val stopHandler = Handler(Looper.getMainLooper())
    private val recordingDurationMilliseconds = 5500
    private val tempRawFile = "temp_record.raw"
    private val bpp = 16

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service created")
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Service started")
        val notification = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setContentTitle("Dexter")
            .setContentText("Listening...")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .build()
        startForeground(NOTIFICATION_ID, notification)
        startListening()
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Service destroyed")
        stopRecording(false)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationChannel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Always Listening Service",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(notificationChannel)
        }
    }

    @SuppressLint("MissingPermission")
    fun startListening() {
        try {
            recorder = AudioRecord(
                MediaRecorder.AudioSource.MIC, sampleRate, channel, audioEncoding, bufferSize
            )
            if (recorder!!.state == AudioRecord.STATE_INITIALIZED) {
                recorder!!.startRecording()
                isRecording = true
            }
            recordingThread = Thread { writeRawData() }
            recordingThread!!.start()

            stopHandler.postDelayed(
                { stopRecording(true) }, recordingDurationMilliseconds.toLong()
            )
        } catch (e: Exception) {
            Log.e(TAG, "Exception : startListening : $e")
        }
    }

    private fun stopRecording(restart: Boolean) {
        try {
            val currentRecorder = recorder ?: return
            isRecording = false
            if (currentRecorder.state == AudioRecord.STATE_INITIALIZED) {
                currentRecorder.stop()
            }
            currentRecorder.release()
            recorder = null
            recordingThread = null
            val rawPath = getPath(tempRawFile)
            createWavFile(rawPath, getPath("final_${System.currentTimeMillis()}_.wav"))
            File(rawPath).delete()
            if (restart) startListening()
            else stopHandler.removeCallbacksAndMessages(null)
        } catch (e: Exception) {
            Log.e(TAG, "Exception : stopRecording : $e")
        }
    }

    private fun createWavFile(tempPath: String, wavPath: String) {
        try {
            FileInputStream(tempPath).use { fileInputStream ->
                FileOutputStream(wavPath).use { fileOutputStream ->
                    val data = ByteArray(bufferSize)
                    val byteRate = (bpp * sampleRate * channelCount / 8).toLong()
                    val totalAudioLen = fileInputStream.channel.size()
                    val totalDataLen = totalAudioLen + 36
                    writeWavHeader(fileOutputStream, totalAudioLen, totalDataLen, byteRate)
                    var bytesRead: Int
                    while (fileInputStream.read(data).also { bytesRead = it } != -1) {
                        fileOutputStream.write(data, 0, bytesRead)
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Exception : createWavFile : $e")
        }
    }

    private fun writeWavHeader(
        fileOutputStream: FileOutputStream,
        totalAudioLen: Long,
        totalDataLen: Long,
        byteRate: Long
    ) {
        try {
            val blockAlign = channelCount * bpp / 8
            val header = ByteArray(44)
            header[0] = 'R'.code.toByte()
            header[1] = 'I'.code.toByte()
            header[2] = 'F'.code.toByte()
            header[3] = 'F'.code.toByte()
            header[4] = (totalDataLen and 0xffL).toByte()
            header[5] = (totalDataLen shr 8 and 0xffL).toByte()
            header[6] = (totalDataLen shr 16 and 0xffL).toByte()
            header[7] = (totalDataLen shr 24 and 0xffL).toByte()
            header[8] = 'W'.code.toByte()
            header[9] = 'A'.code.toByte()
            header[10] = 'V'.code.toByte()
            header[11] = 'E'.code.toByte()
            header[12] = 'f'.code.toByte()
            header[13] = 'm'.code.toByte()
            header[14] = 't'.code.toByte()
            header[15] = ' '.code.toByte()
            header[16] = 16
            header[17] = 0
            header[18] = 0
            header[19] = 0
            header[20] = 1 // PCM format
            header[21] = 0
            header[22] = channelCount.toByte()
            header[23] = 0
            header[24] = (sampleRate.toLong() and 0xffL).toByte()
            header[25] = (sampleRate.toLong() shr 8 and 0xffL).toByte()
            header[26] = (sampleRate.toLong() shr 16 and 0xffL).toByte()
            header[27] = (sampleRate.toLong() shr 24 and 0xffL).toByte()
            header[28] = (byteRate and 0xffL).toByte()
            header[29] = (byteRate shr 8 and 0xffL).toByte()
            header[30] = (byteRate shr 16 and 0xffL).toByte()
            header[31] = (byteRate shr 24 and 0xffL).toByte()
            header[32] = blockAlign.toByte()
            header[33] = 0
            header[34] = bpp.toByte()
            header[35] = 0
            header[36] = 'd'.code.toByte()
            header[37] = 'a'.code.toByte()
            header[38] = 't'.code.toByte()
            header[39] = 'a'.code.toByte()
            header[40] = (totalAudioLen and 0xffL).toByte()
            header[41] = (totalAudioLen shr 8 and 0xffL).toByte()
            header[42] = (totalAudioLen shr 16 and 0xffL).toByte()
            header[43] = (totalAudioLen shr 24 and 0xffL).toByte()
            fileOutputStream.write(header, 0, 44)
        } catch (e: Exception) {
            Log.e(TAG, "Exception : writeWavHeader : $e")
        }
    }

    private fun writeRawData() {
        try {
            val data = ByteArray(bufferSize)
            FileOutputStream(getPath(tempRawFile)).use { fileOutputStream ->
                while (isRecording) {
                    val read = recorder!!.read(data, 0, bufferSize)
                    if (read > 0) {
                        try {
                            fileOutputStream.write(data, 0, read)
                        } catch (e: IOException) {
                            Log.e(TAG, "Exception : writeRawData>fileOutputStream : $e")
                        }
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Exception : writeRawData : $e")
        }
    }

    private fun getPath(name: String): String = "$filesDir/$name"

    companion object {
        const val TAG = "AlwaysListeningService"
        private const val NOTIFICATION_CHANNEL_ID = "always_listening_channel"
        private const val NOTIFICATION_ID = 1
    }
}
