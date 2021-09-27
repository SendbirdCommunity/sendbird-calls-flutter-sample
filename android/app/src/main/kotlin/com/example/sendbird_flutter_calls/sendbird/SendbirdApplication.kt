package com.example.sendbird_flutter_calls.sendbird

import android.app.Application
import android.content.Context

class SendbirdApplication : Application() {

    companion object {
        var ctx: Context? = null
        var pushToken: String? = null
    }

    override fun onCreate() {
        super.onCreate()
        ctx = applicationContext
    }
}