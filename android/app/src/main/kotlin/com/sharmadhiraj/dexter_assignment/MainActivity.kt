package com.sharmadhiraj.dexter_assignment


import android.content.Intent
import android.os.Bundle
import com.sharmadhiraj.dexter_assignment.service.AlwaysListeningService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "com.sharmadhiraj.always_listening_service/data"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Dexter.methodChannel.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            if (call.method == "startService") {
                startService()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startService() {
        startService(Intent(this, AlwaysListeningService::class.java))
    }

}

