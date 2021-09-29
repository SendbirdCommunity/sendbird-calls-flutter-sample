package com.example.sendbird_flutter_calls.sendbird;

import android.content.Context;
import android.util.Log;

import com.sendbird.calls.DirectCall;
import com.sendbird.calls.SendBirdCall;
import com.sendbird.calls.handler.DirectCallListener;
import com.sendbird.calls.handler.SendBirdCallListener;

import java.util.UUID;

import io.flutter.plugin.common.MethodChannel;

public class SendbirdCommands {

    public static final String TAG = "SendBirdCommands";

    public interface InitHandler {
        void onResult(boolean isSuccess);
    }

    public void initSendBirdCall(Context context, String appId, MethodChannel channel, InitHandler callback) {
        Log.i(TAG, "initSendBirdCall(appId: " + appId + ")");

        if (SendBirdCall.init(context, appId)) {
            SendBirdCall.removeAllListeners();
            SendBirdCall.addListener(UUID.randomUUID().toString(), new SendBirdCallListener() {

                // The onRinging function has an issue where it currently can not be called in a
                // Kotlin file so it must be configured in this java file
                @Override
                public void onRinging(DirectCall call) {

                    Log.i(TAG, "onRinging detected");

                    channel.invokeMethod("direct_call_received", null);

                    call.setListener(new DirectCallListener() {
                        @Override
                        public void onConnected(DirectCall call) {
                            channel.invokeMethod("direct_call_connected", null);
                        }

                        @Override
                        public void onEnded(DirectCall call) {
                            channel.invokeMethod("direct_call_ended", null);

                        }
                    });

                }
            });
            callback.onResult(true);
            return;
        }
        callback.onResult(false);
    }
}
