package com.sharmadhiraj.dexter_assignment.service

import android.Manifest
import android.app.Service
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import android.widget.Toast
import androidx.core.app.ActivityCompat
import com.sharmadhiraj.dexter_assignment.Dexter
import java.io.File
import java.io.FileOutputStream
import java.io.RandomAccessFile
import java.util.Timer
import java.util.TimerTask

class AlwaysListeningService : Service() {


    private var isListening = false
    private var audioRecord: AudioRecord? = null


    private var timer: Timer? = null

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service created")

    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Service started")
        if (!isListening) {
            startListening()
        } else {
//            stopListening()
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Service destroyed")
        stopListening()
    }

    private fun startListening() {
        isListening = true
        Log.d(TAG, "Started listening")

        val minBufferSize = AudioRecord.getMinBufferSize(
            SAMPLE_RATE, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT
        )

        if (ActivityCompat.checkSelfPermission(
                this, Manifest.permission.RECORD_AUDIO
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            Toast.makeText(
                this,
                "Kindly grant the app permission to record audio by navigating to the app settings.",
                Toast.LENGTH_LONG
            ).show()
            return
        }

        audioRecord = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            minBufferSize
        )
        audioRecord?.startRecording()

        timer = Timer()
        timer?.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                if (isListening) {
                    val buffer = ByteArray(minBufferSize)
                    val bytesRead = audioRecord?.read(buffer, 0, buffer.size) ?: 0
                    if (bytesRead > 0) {
                        val fileName = "audio_${System.currentTimeMillis()}.wav"
                        Log.d(TAG, "Writing wav file $fileName")
                        val audioFile = File(filesDir, fileName)
                        writeWavHeader(audioFile)
                        val output = FileOutputStream(audioFile, true)
                        output.write(buffer, 0, bytesRead)
                        output.close()
                        sendFilePath(audioFile.path)
                    }
                }
            }
        }, 0, 5000)
    }

    private fun writeWavHeader(audioFile: File) {
        try {
            val output = RandomAccessFile(audioFile, "rw")

            // Set file length at the beginning to update the header
            output.seek(0)
            output.writeBytes("RIFF")
            output.writeInt(Integer.reverseBytes((output.length() - 8).toInt()))
            output.writeBytes("WAVE")
            output.writeBytes("fmt ")
            output.writeInt(Integer.reverseBytes(16))  // Sub-chunk size, 16 for PCM
            output.writeShort(1.toShort().reverseByteOrder().toInt())  // AudioFormat, 1 for PCM
            output.writeShort(1.toShort().reverseByteOrder().toInt())  // NumChannels, 1 for mono
            output.writeInt(Integer.reverseBytes(SAMPLE_RATE))  // SampleRate
            output.writeInt(Integer.reverseBytes(SAMPLE_RATE * 16 / 8))  // ByteRate
            output.writeShort((16 / 8).toShort().reverseByteOrder().toInt())  // BlockAlign
            output.writeShort(16.toShort().reverseByteOrder().toInt())  // BitsPerSample
            output.writeBytes("data")
            output.writeInt(Integer.reverseBytes((output.length() - 44).toInt()))

            output.close()
        } catch (e: Exception) {
            Log.e(TAG, "Error writing WAV header: ${e.message}")
        }
    }

    private fun Short.reverseByteOrder(): Short {
        return ((this.toInt() and 0xFF) shl 8 or ((this.toInt() and 0xFF00) ushr 8)).toShort()
    }

    private fun sendFilePath(filePath: String) {
        Handler(Looper.getMainLooper()).post {
            Dexter.methodChannel.invokeMethod("onFilePath", filePath)
        }
    }

    private fun stopListening() {
        Log.d(TAG, "Stopped listening")
        isListening = false
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
    }


    companion object {
        const val TAG = "AlwaysListeningService"
        const val SAMPLE_RATE = 44100
    }
}
