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

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FLUTTER_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startService" -> {
                        requestAudioPermissionOrStart(); result.success(null)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun requestAudioPermissionOrStart() {
        if (hasAudioPermission()) {
            launchListeningService()
        } else {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.RECORD_AUDIO),
                AUDIO_PERMISSION_REQUEST
            )
        }
    }

    private fun hasAudioPermission() = ContextCompat.checkSelfPermission(
        this, Manifest.permission.RECORD_AUDIO
    ) == PackageManager.PERMISSION_GRANTED

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != AUDIO_PERMISSION_REQUEST) return
        if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
            launchListeningService()
        } else {
            Toast.makeText(
                this,
                "Microphone permission is required. Enable it in app settings.",
                Toast.LENGTH_LONG
            ).show()
        }
    }

    private fun launchListeningService() {
        startService(Intent(this, AlwaysListeningService::class.java))
    }

    companion object {
        private const val FLUTTER_CHANNEL = "com.sharmadhiraj.always_listening_service/data"
        private const val AUDIO_PERMISSION_REQUEST = 123
    }
}
