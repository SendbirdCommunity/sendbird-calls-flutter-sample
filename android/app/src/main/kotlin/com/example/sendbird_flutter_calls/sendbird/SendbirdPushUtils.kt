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

    private val TAG = "SendbirdCalls-PushUtils"

    private fun getSharedPreferences(context: Context): SharedPreferences {
        return context.getSharedPreferences("sendbird_calls", Context.MODE_PRIVATE)
    }

    fun setPushToken(context: Context, pushToken: String?) {
        val editor = getSharedPreferences(context).edit()
        editor.putString("push_token", pushToken).apply()
    }

    fun getPushToken(context: Context): String? {
        return getSharedPreferences(context).getString("push_token", "")
    }

    interface GetPushTokenHandler {
        fun onResult(token: String?, e: SendBirdException?)
    }

    fun getPushToken(context: Context, handler: GetPushTokenHandler?) {
        Log.i(TAG, "[PushUtils] getPushToken()");
        val savedToken = getPushToken(context)
        if (TextUtils.isEmpty(savedToken)) {
            FirebaseInstanceId.getInstance().instanceId.addOnCompleteListener { task: Task<InstanceIdResult?> ->
                if (!task.isSuccessful) {
                    Log.i(TAG, "[PushUtils] getPushToken() => getInstanceId failed", task.getException());
                    handler?.onResult(
                        null,
                        SendBirdException(if (task.exception != null) task.exception!!.message else "")
                    )
                    return@addOnCompleteListener
                }
                val pushToken =
                    if (task.result != null) task.result!!.token else ""
                                Log.i(TAG, "[PushUtils] getPushToken() => pushToken: " + pushToken);
                handler?.onResult(pushToken, null)
            }
        } else {
            Log.i(TAG, "[PushUtils] savedToken: " + savedToken);
            handler?.onResult(savedToken, null)
        }
    }

    interface PushTokenHandler {
        fun onResult(e: SendBirdException?)
    }

    fun registerPushToken(context: Context, pushToken: String, handler: PushTokenHandler?) {
        Log.i(TAG, "[PushUtils] registerPushToken(pushToken: " + pushToken + ")");
        registerPushToken(pushToken, false, object : CompletionHandler {
            override fun onResult(e: SendBirdException?) {
                if (e != null) {
                Log.i(TAG, "[PushUtils] registerPushToken() => e: " + e.message);
                    setPushToken(context, pushToken)
                    handler?.onResult(e)
                    return
                }

            Log.i(TAG, "[PushUtils] registerPushToken() => OK");
                setPushToken(context, pushToken)
                handler?.onResult(null)
            }
        })
    }
}
}