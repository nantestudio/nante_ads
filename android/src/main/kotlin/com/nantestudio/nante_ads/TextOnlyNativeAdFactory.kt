package com.nantestudio.nante_ads

import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

/**
 * Text-only native ad factory for minimal single-line ads.
 *
 * Uses only the headline text - no MediaView - to avoid video size
 * requirements while maintaining native ad CPM rates.
 */
class TextOnlyNativeAdFactory(private val layoutInflater: LayoutInflater) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = layoutInflater.inflate(
            R.layout.nante_text_only_native,
            null
        ) as NativeAdView

        // Headline is the only required asset for text-only ads
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        adView.setNativeAd(nativeAd)
        return adView
    }
}
