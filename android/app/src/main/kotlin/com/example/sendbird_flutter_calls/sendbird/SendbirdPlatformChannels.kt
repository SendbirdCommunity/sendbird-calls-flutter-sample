package com.example.sendbird_flutter_calls.sendbird

import android.content.Context
import android.util.Log
import com.sendbird.calls.*
import com.sendbird.calls.handler.AuthenticateHandler
import com.sendbird.calls.handler.CompletionHandler
import com.sendbird.calls.handler.DialHandler
import com.sendbird.calls.handler.DirectCallListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class SendbirdPlatformChannels {

        private val TAG = "SendbirdPlatformChannel"
        private val METHOD_CHANNEL_NAME = "com.sendbird.calls/method"
        private val ERROR_CODE = "Sendbird Calls"
        private var methodChannel: MethodChannel? = null
        private var directCall: DirectCall? = null
        private var sendbirdCommands = SendbirdCommands()

        fun setupChannels(context: Context, messenger: BinaryMessenger) {
            methodChannel = MethodChannel(messenger, METHOD_CHANNEL_NAME)
            methodChannel!!.setMethodCallHandler { call, result ->
                when(call.method) {
                    "init" -> {
                        val appId: String? = call.argument("app_id")
                        val userId: String? = call.argument("user_id")
                        when {
                            appId == null -> {
                                result.error(ERROR_CODE, "Failed Init", "Missing app_id")
                            }
                            userId == null -> {
                                result.error(ERROR_CODE, "Failed Init", "Missing user_id")
                            }
                            else -> {
                                sendbirdCommands.initSendBirdCall(context, appId!!, methodChannel!!
                                ) {
                                    // Successfully connected with Sendbird
                                    authenticate(context, userId) { success ->
                                        if (!success){
                                            Log.i(TAG, "Failed to authenticate user, check userId.")
                                        }
                                        // Successfully authenticated userId with Sendbird
                                        result.success(success)
                                    }
                                }
                            }
                        }
                    }
                    "start_direct_call" -> {
                        val calleeId: String? = call.argument("callee_id")
                        if (calleeId == null) {
                            result.error(ERROR_CODE, "Failed call", "Missing callee_id")
                        }
                        var params = DialParams(calleeId!!)
                        params.setCallOptions(CallOptions())
                        directCall = SendBirdCall.dial(params, object : DialHandler {
                            override fun onResult(call: DirectCall?, e: SendBirdException?) {
                                if (e != null) {
                                    result.error(ERROR_CODE, "Failed call", e.message)
                                    return
                                }
                                result.success(true)
                            }
                        })
                        directCall?.setListener(object : DirectCallListener() {
                            override fun onEstablished(call: DirectCall) {}
                            override fun onConnected(call: DirectCall) {}
                            override fun onEnded(call: DirectCall) {}
                        })
                    }
                    "answer_direct_call"->{
                        directCall?.accept(AcceptParams())
                        result.success(true)
                    }
                    "end_direct_call" -> {
                        directCall?.end();
                        result.success(true)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
        }

        fun disposeChannels(){
            methodChannel!!.setMethodCallHandler(null)
        }

        fun authenticate(context: Context, userId: String, callback: (Boolean)->Unit) {

            if (SendBirdCall.currentUser != null){
                // Already authenticated
                Log.i(TAG, "authenticate: already authenticated")
                callback(true)
                return
            }

            var params = AuthenticateParams(userId)
            SendBirdCall.authenticate(params, object : AuthenticateHandler {
                override fun onResult(user: User?, e: SendBirdException?) {
                    if (e == null) {
                        // The user has been authenticated successfully and is connected to Sendbird server.

                        // Register push token (if available) with Sendbird now that user is authenticated
                        val token = SendbirdPushUtils.Companion.getPushToken(context)
                        if (token != null) {
                            SendBirdCall.registerPushToken(
                                token,
                                false,
                                object : CompletionHandler {
                                    override fun onResult(e: SendBirdException?) {
                                        if (e != null) {
                                            Log.i(TAG,"registerPushToken() => e: " + e.message)
                                            SendbirdPushUtils.setPushToken(context, token)
                                            return
                                        }

                                        Log.i(TAG,"registerPushToken() => OK")
                                        SendbirdPushUtils.setPushToken(context, token)
                                    }
                                })
                        } else {
                            Log.i(TAG, "");
                        }
                        callback(true)
                    } else {
                        callback(false)
                    }
                }
            })
        }
}