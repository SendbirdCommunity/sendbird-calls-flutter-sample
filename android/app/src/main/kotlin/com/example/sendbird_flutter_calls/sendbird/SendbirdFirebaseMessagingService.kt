package com.example.sendbird_flutter_calls.sendbird

import android.os.Handler
import android.os.Looper
import com.example.sendbird_flutter_calls.sendbird.SendbirdPushUtils.Companion.setPushToken
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import android.util.Log
import com.sendbird.calls.SendBirdCall

class SendbirdFirebaseMessagingService : FirebaseMessagingService() {

    private val TAG = "SendbirdFirebaseMessagingService"

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
            val user = SendBirdCall.currentUser
            if (user == null){
                Log.i(TAG, "[SendbirdFirebaseMessagingService] sendbird user not authenticated");
            } else {
                if (SendBirdCall.handleFirebaseMessageData(remoteMessage.data)) {
                    Log.i(TAG,"[SendbirdFirebaseMessagingService] onMessageReceived() => " + remoteMessage.data.toString());
                }
            }
    }

    override fun onNewToken(token: String) {
        Log.i(TAG, "[SendbirdFirebaseMessagingService] onNewToken(token: $token)");
        // Save push token for later use by SendbirdPlatformChannels
        setPushToken(applicationContext, token)
    }
}