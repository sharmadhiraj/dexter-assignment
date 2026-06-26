package com.sharmadhiraj.dexter_assignment

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.sharmadhiraj.dexter_assignment.service.AlwaysListeningService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private val recordAudioPermissionRequestCode = 123
    private val channelName = "com.sharmadhiraj.always_listening_service/data"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "startService") {
                    checkPermissionThenStartService()
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun checkPermissionThenStartService() {
        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.RECORD_AUDIO
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.RECORD_AUDIO),
                recordAudioPermissionRequestCode
            )
            return
        }
        startService()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when (requestCode) {
            recordAudioPermissionRequestCode -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    startService()
                } else {
                    Toast.makeText(
                        this,
                        "Kindly grant the app permission to record audio by navigating to the app settings.",
                        Toast.LENGTH_LONG
                    ).show()
                }
            }
        }
    }

    private fun startService() {
        startService(Intent(this, AlwaysListeningService::class.java))
    }
}
