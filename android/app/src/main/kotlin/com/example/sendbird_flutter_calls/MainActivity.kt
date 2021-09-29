package com.example.sendbird_flutter_calls

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine


import com.example.sendbird_flutter_calls.sendbird.SendbirdPlatformChannels


class MainActivity: FlutterActivity() {

    var sendbirdPlatformChannels = SendbirdPlatformChannels()

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup
        sendbirdPlatformChannels.setupChannels(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onDestroy() {

        // Cleanup
        sendbirdPlatformChannels.disposeChannels()
        super.onDestroy()
    }

}
