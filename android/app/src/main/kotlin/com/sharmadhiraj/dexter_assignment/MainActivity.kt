package com.sharmadhiraj.dexter_assignment


import android.content.Intent
import android.os.Bundle
import com.sharmadhiraj.dexter_assignment.service.AlwaysListeningService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private val channel = "com.sharmadhiraj.always_listening_service/data"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(FlutterEngine(this))

        flutterEngine?.dartExecutor?.binaryMessenger?.let {
            MethodChannel(it, channel)
                .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                    if (call.method == "startService") {
                        startService()
                        result.success(null)
                    } else {
                        result.notImplemented()
                    }
                }
        }
    }

    private fun startService() {
        startService(Intent(this, AlwaysListeningService::class.java))
    }

}

