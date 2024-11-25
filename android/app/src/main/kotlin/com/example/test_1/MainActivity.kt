package com.example.test_1


import android.media.MediaPlayer
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    private val CHANNEL = "samples.flutter.dev/sound"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "playSound") {
                val soundName = call.argument<String>("sound")
                playSound(soundName)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun playSound(soundName: String?) {
        val soundResId = when (soundName) {
            "correct" -> R.raw.correct
            "incorrect" -> R.raw.incorrect
            else -> 0
        }

        if (soundResId != 0) {
            val mediaPlayer = MediaPlayer.create(this, soundResId)
            mediaPlayer?.apply {
                start()
                setOnCompletionListener { mp -> mp.release() }
            }
        }
    }
}