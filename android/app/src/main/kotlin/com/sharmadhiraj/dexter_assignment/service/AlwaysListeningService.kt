package com.sharmadhiraj.dexter_assignment.service

import android.annotation.SuppressLint
import android.app.Service
import android.content.Intent
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import com.sharmadhiraj.dexter_assignment.Dexter
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException

class AlwaysListeningService : Service() {


    private var recorder: AudioRecord? = null
    private var sampleRate = 44100
    private var channel = AudioFormat.CHANNEL_IN_STEREO
    private var audioEncoding = AudioFormat.ENCODING_PCM_16BIT
    private var bufferSize = AudioRecord.getMinBufferSize(
        8000,
        AudioFormat.CHANNEL_IN_MONO,
        AudioFormat.ENCODING_PCM_16BIT
    )
    private var recordingThread: Thread? = null
    private var isRecording = false
    private val stopHandler = Handler(Looper.getMainLooper())
    private val recordingDurationMilliseconds = 5500
    private var tempRawFile = "temp_record.raw"
    private val bpp = 16

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service created")

    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Service started")
        startListening()
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Service destroyed")
        stopRecording(false)
    }


    @SuppressLint("MissingPermission")
    fun startListening() {
        try {
            recorder = AudioRecord(
                MediaRecorder.AudioSource.MIC,
                sampleRate,
                channel,
                audioEncoding,
                bufferSize
            )
            val status = recorder!!.state
            if (status == 1) {
                recorder!!.startRecording()
                isRecording = true
            }
            recordingThread = Thread { writeRawData() }
            recordingThread!!.start()

            stopHandler.postDelayed(
                { stopRecording(true) },
                recordingDurationMilliseconds.toLong()
            )
        } catch (e: Exception) {
            Log.e(TAG, "Exception : startListening : $e")
        }
    }


    private fun stopRecording(restart: Boolean) {
        try {
            if (recorder != null) {
                isRecording = false
                val status = recorder!!.state
                if (status == 1) {
                    recorder!!.stop()
                }
                recorder!!.release()
                recordingThread = null
                createWavFile(
                    getPath(tempRawFile),
                    getPath("final_${System.currentTimeMillis()}_.wav")
                )
                if (restart)
                    startListening()
                else
                    stopHandler.removeCallbacksAndMessages(null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Exception : stopRecording : $e")
        }
    }


    private fun createWavFile(tempPath: String, wavPath: String) {
        try {
            val fileInputStream = FileInputStream(tempPath)
            val fileOutputStream = FileOutputStream(wavPath)
            val data = ByteArray(bufferSize)
            val channels = 2
            val byteRate = (bpp * sampleRate * channels / 8).toLong()
            val totalAudioLen = fileInputStream.channel.size()
            val totalDataLen = totalAudioLen + 36
            writeWavHeader(fileOutputStream, totalAudioLen, totalDataLen, channels, byteRate)
            while (fileInputStream.read(data) != -1) {
                fileOutputStream.write(data)
            }
            fileInputStream.close()
            fileOutputStream.close()
            sendFilePath(wavPath)
        } catch (e: Exception) {
            Log.e(TAG, "Exception : createWavFile : $e")
        }
    }


    private fun writeWavHeader(
        fileOutputStream: FileOutputStream,
        totalAudioLen: Long,
        totalDataLen: Long,
        channels: Int,
        byteRate: Long
    ) {
        try {
            val header = ByteArray(44)
            header[0] = 'R'.code.toByte() // RIFF/WAVE header
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
            header[12] = 'f'.code.toByte() // 'fmt ' chunk
            header[13] = 'm'.code.toByte()
            header[14] = 't'.code.toByte()
            header[15] = ' '.code.toByte()
            header[16] = 16 // 4 bytes: size of 'fmt ' chunk
            header[17] = 0
            header[18] = 0
            header[19] = 0
            header[20] = 1 // format = 1
            header[21] = 0
            header[22] = channels.toByte()
            header[23] = 0
            header[24] = (sampleRate.toLong() and 0xffL).toByte()
            header[25] = (sampleRate.toLong() shr 8 and 0xffL).toByte()
            header[26] = (sampleRate.toLong() shr 16 and 0xffL).toByte()
            header[27] = (sampleRate.toLong() shr 24 and 0xffL).toByte()
            header[28] = (byteRate and 0xffL).toByte()
            header[29] = (byteRate shr 8 and 0xffL).toByte()
            header[30] = (byteRate shr 16 and 0xffL).toByte()
            header[31] = (byteRate shr 24 and 0xffL).toByte()
            header[32] = (2 * 16 / 8).toByte() // block align
            header[33] = 0
            header[34] = bpp.toByte() // bits per sample
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
            val path = getPath(tempRawFile)
            val fileOutputStream = FileOutputStream(path)
            var read: Int
            while (isRecording) {
                read = recorder!!.read(data, 0, bufferSize)
                if (AudioRecord.ERROR_INVALID_OPERATION != read) {
                    try {
                        fileOutputStream.write(data)
                    } catch (e: IOException) {
                        Log.e(TAG, "Exception : writeRawData>fileOutputStream : $e")
                    }
                }
            }
            fileOutputStream.close()
        } catch (e: Exception) {
            Log.e(TAG, "Exception : writeRawData : $e")
        }
    }

    private fun sendFilePath(filePath: String) {
        Handler(Looper.getMainLooper()).post {
            Dexter.methodChannel.invokeMethod("onFilePath", filePath)
        }
    }


    private fun getPath(name: String): String {
        return "$filesDir/$name"
    }

    companion object {
        const val TAG = "AlwaysListeningService"
        const val SAMPLE_RATE = 44100
    }
}
