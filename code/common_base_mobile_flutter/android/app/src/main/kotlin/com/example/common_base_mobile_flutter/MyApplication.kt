package com.example.common_base_mobile_flutter

import android.app.Application
import android.content.res.Configuration
import android.content.res.Resources
import java.util.Locale
import com.baidu.mapapi.SDKInitializer
import com.baidu.mapapi.base.BmfMapApplication
import com.baidu.mapapi.common.BaiduMapSDKException
import com.baidu.mapapi.map.OverlayUtil

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        
        BmfMapApplication.mContext = applicationContext
        
        try {
            SDKInitializer.setAgreePrivacy(this, true)
            SDKInitializer.initialize(this)
            OverlayUtil.setOverlayUpgrade(false)
        } catch (e: BaiduMapSDKException) {
            e.message
        }
    }
    
    override fun attachBaseContext(base: android.content.Context) {
        val context = setLocale(base)
        super.attachBaseContext(context)
    }
    
    private fun setLocale(context: android.content.Context): android.content.Context {
        val resources: Resources = context.resources
        val config: Configuration = resources.configuration
        config.setLocale(Locale.CHINESE)
        return context.createConfigurationContext(config)
    }
}
