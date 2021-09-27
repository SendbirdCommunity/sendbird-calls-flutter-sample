package com.example.sendbird_flutter_calls.sendbird

import com.example.sendbird_flutter_calls.sendbird.SendbirdPushUtils.Companion.PushTokenHandler
import com.example.sendbird_flutter_calls.sendbird.SendbirdPushUtils.Companion.registerPushToken
import com.example.sendbird_flutter_calls.sendbird.SendbirdPushUtils.Companion.setPushToken
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.sendbird.calls.SendBirdCall.currentUser
import com.sendbird.calls.SendBirdCall.handleFirebaseMessageData
import com.sendbird.calls.SendBirdException
import android.util.Log

class SendbirdFirebaseMessagingService : FirebaseMessagingService() {

    private val TAG = "SendbirdCalls-FirebaseMessagingService"

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        if (handleFirebaseMessageData(remoteMessage.data)) {
            Log.i(TAG, "[MyFirebaseMessagingService] onMessageReceived() => " + remoteMessage.getData().toString());
        }
    }

    override fun onNewToken(token: String) {
        Log.i(TAG, "[MyFirebaseMessagingService] onNewToken(token: " + token + ")");
        if (currentUser != null) {
            registerPushToken(applicationContext, token, PushTokenHandler { e: SendBirdException? ->
                if (e != null) {
                    Log.i(TAG, "[MyFirebaseMessagingService] registerPushTokenForCurrentUser() => e: " + e.getMessage());
                }
            })
        } else {
            setPushToken(applicationContext, token)
        }
    }
}