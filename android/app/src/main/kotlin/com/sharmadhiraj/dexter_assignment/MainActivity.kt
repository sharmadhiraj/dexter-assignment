package com.sharmadhiraj.dexter_assignment


import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.sharmadhiraj.dexter_assignment.service.AlwaysListeningService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val RECORD_AUDIO_PERMISSION_REQUEST_CODE = 123

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Dexter.methodChannel.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
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
            // Request audio recording permission
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.RECORD_AUDIO),
                RECORD_AUDIO_PERMISSION_REQUEST_CODE
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
        when (requestCode) {
            RECORD_AUDIO_PERMISSION_REQUEST_CODE -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    // Permission granted, continue with the service
                    startService()
                } else {
                    // Permission denied, show a message or take appropriate action
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

