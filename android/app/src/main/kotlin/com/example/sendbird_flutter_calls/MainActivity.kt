package com.example.sendbird_flutter_calls

import android.content.BroadcastReceiver
import android.content.Context
import androidx.annotation.NonNull
import com.sendbird.calls.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import com.sendbird.calls.handler.AuthenticateHandler
import com.sendbird.calls.handler.DirectCallListener
import com.sendbird.calls.handler.SendBirdCallListener
import java.util.*

class MainActivity: FlutterActivity() {
    private val METHOD_CHANNEL_NAME = "com.sendbird.calls/method"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup
        setupChannels(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onDestroy() {
        disposeChannels()
        super.onDestroy()
    }

    private fun setupChannels(context:Context, messenger: BinaryMessenger){
            methodChannel = MethodChannel(messenger, METHOD_CHANNEL_NAME)
            methodChannel!!.setMethodCallHandler{call, result ->
                if (call.method == "init"){
                    val appId: String? = call.argument("app_id")
                    val userId: String? = call.argument("user_id")
                    if (appId == null) {
                        result.error("Sendbird Calls", "Failed Init", "Missing app_id")
                    } else if (userId == null) {
                        result.error("Sendbird Calls", "Failed Init", "Missing user_id")
                    } else {
                        initSendbird(context, appId!!, userId!!) { successful ->
                            if (!successful) {
                                result.error("Sendbird Calls", "Failed init", "Problem initializing Sendbird. Check for valid app_id")
                            } else {
                                result.success(true)
                            }
                        }
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun initSendbird(context: Context, appId: String , userId: String, callback: (Boolean)->Unit){
        // Initialize SendBirdCall instance to use APIs in your app.
        if(SendBirdCall.init(context, appId)){
            // Initialization successful
            SendBirdCall.addListener(UUID.randomUUID().toString(), object: SendBirdCallListener() {
                override fun onRinging(call: DirectCall) {
                    val ongoingCallCount = SendBirdCall.ongoingCallCount
                    if (ongoingCallCount >= 2) {
                        call.end()
                        return
                    }

                    call.setListener(object : DirectCallListener() {
                        override fun onConnected(call: DirectCall) {

                        }

                        override fun onEnded(call: DirectCall) {
                            val ongoingCallCount = SendBirdCall.ongoingCallCount
                            if (ongoingCallCount == 0) {
//                                CallService.stopService(context)
                            }
                        }
                    })
                }
            })
        }

        // The USER_ID below should be unique to your Sendbird application.
        var params = AuthenticateParams(userId)

        SendBirdCall.authenticate(params, object : AuthenticateHandler {
            override fun onResult(user: User?, e: SendBirdException?) {
                    if (e == null) {
                        // The user has been authenticated successfully and is connected to Sendbird server.
                        callback(true)
                    } else {
                        callback(false)
                    }
                }
            })
    }

    private fun disposeChannels(){
        methodChannel!!.setMethodCallHandler(null)
    }
}
