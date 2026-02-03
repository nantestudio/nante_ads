package com.nantestudio.nante_ads

import android.content.Context
import android.view.LayoutInflater
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

/**
 * NanteAdsPlugin automatically registers the text-only native ad factory
 * with the Google Mobile Ads plugin.
 *
 * Factory ID: "nanteTextOnly"
 */
class NanteAdsPlugin : FlutterPlugin {

    companion object {
        const val FACTORY_ID = "nanteTextOnly"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val context = binding.applicationContext
        val layoutInflater = LayoutInflater.from(context)

        GoogleMobileAdsPlugin.registerNativeAdFactory(
            binding.flutterEngine,
            FACTORY_ID,
            TextOnlyNativeAdFactory(layoutInflater)
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            binding.flutterEngine,
            FACTORY_ID
        )
    }
}
