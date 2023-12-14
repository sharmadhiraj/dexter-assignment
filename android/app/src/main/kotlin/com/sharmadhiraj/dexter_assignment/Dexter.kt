package com.sharmadhiraj.dexter_assignment

import android.app.Application
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class Dexter : Application() {

    companion object {
        lateinit var methodChannel: MethodChannel
    }


    private val channelName = "com.sharmadhiraj.always_listening_service/data"
    override fun onCreate() {
        super.onCreate()

        val flutterEngine = FlutterEngine(applicationContext)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
    }
}