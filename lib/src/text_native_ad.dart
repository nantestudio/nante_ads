import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Factory ID used to identify the text-only native ad factory.
/// Must match the ID registered in platform code.
const String kTextNativeAdFactoryId = 'nanteTextOnly';

/// A text-only native ad that displays in a minimal single-line format.
///
/// This class wraps [NativeAd] and configures it to use the text-only
/// factory registered by this plugin.
class TextNativeAd {
  TextNativeAd({
    required this.adUnitId,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClicked,
    this.onAdImpression,
  });

  final String adUnitId;
  final void Function(NativeAd ad)? onAdLoaded;
  final void Function(NativeAd ad, LoadAdError error)? onAdFailedToLoad;
  final void Function(NativeAd ad)? onAdClicked;
  final void Function(NativeAd ad)? onAdImpression;

  NativeAd? _nativeAd;
  bool _isLoaded = false;

  /// Whether the ad has been successfully loaded.
  bool get isLoaded => _isLoaded;

  /// The underlying [NativeAd] instance.
  NativeAd? get nativeAd => _nativeAd;

  /// Load the ad.
  Future<void> load() async {
    if (kDebugMode) {
      debugPrint('TextNativeAd: loading ad with factoryId=$kTextNativeAdFactoryId, adUnitId=$adUnitId');
    }
    _nativeAd?.dispose();
    _isLoaded = false;

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: kTextNativeAdFactoryId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _isLoaded = true;
          onAdLoaded?.call(ad as NativeAd);
        },
        onAdFailedToLoad: (ad, error) {
          _isLoaded = false;
          ad.dispose();
          _nativeAd = null;
          onAdFailedToLoad?.call(ad as NativeAd, error);
          if (kDebugMode) {
            debugPrint('TextNativeAd failed to load: ${error.message}');
          }
        },
        onAdClicked: (ad) => onAdClicked?.call(ad as NativeAd),
        onAdImpression: (ad) => onAdImpression?.call(ad as NativeAd),
      ),
      request: const AdRequest(),
    );

    await _nativeAd!.load();
    if (kDebugMode) {
      debugPrint('TextNativeAd: load() call completed');
    }
  }

  /// Dispose of the ad and release resources.
  void dispose() {
    _nativeAd?.dispose();
    _nativeAd = null;
    _isLoaded = false;
  }
}
