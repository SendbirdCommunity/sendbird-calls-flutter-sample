package com.example.sendbird_flutter_calls.sendbird

import android.content.Context
import android.content.SharedPreferences
import android.text.TextUtils
import com.google.android.gms.tasks.Task
import com.google.firebase.iid.FirebaseInstanceId
import com.google.firebase.iid.InstanceIdResult
import com.sendbird.calls.SendBirdCall.registerPushToken
import com.sendbird.calls.SendBirdException
import com.sendbird.calls.handler.CompletionHandler
import android.util.Log

class SendbirdPushUtils {

companion object {

    private const val TAG = "SendbirdPushUtils"
    private const val PUSH_TOKEN_KEY = "push_token"


    private fun getSharedPreferences(context: Context): SharedPreferences {
        return context.getSharedPreferences("sendbird_calls", Context.MODE_PRIVATE)
    }

    fun setPushToken(context: Context, pushToken: String?) {
        val editor = getSharedPreferences(context).edit()
        Log.i(TAG, "[PushUtils] setPushToken: $pushToken)");
        editor.putString(PUSH_TOKEN_KEY, pushToken).apply()
    }

    fun getPushToken(context: Context): String? {
        val token = getSharedPreferences(context).getString(PUSH_TOKEN_KEY, "")
        Log.i(TAG, "[PushUtils] getPushToken: $token)");
        return token
    }

//    interface PushTokenHandler {
//        fun onResult(e: SendBirdException?)
//    }

//    fun registerPushToken(context: Context, pushToken: String, handler: PushTokenHandler?) {
//        Log.i(TAG, "[PushUtils] registerPushToken(pushToken: $pushToken)");
//        registerPushToken(pushToken, false, object : CompletionHandler {
//            override fun onResult(e: SendBirdException?) {
//                if (e != null) {
//                    Log.i(TAG, "[PushUtils] registerPushToken() => e: " + e.message);
//                    setPushToken(context, pushToken)
//                    handler?.onResult(e)
//                    return
//                }
//
//                Log.i(TAG, "[PushUtils] registerPushToken() => OK");
//                setPushToken(context, pushToken)
//                handler?.onResult(null)
//            }
//        })
//    }
}
}