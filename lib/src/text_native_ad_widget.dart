import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'text_native_ad.dart';

/// Height of the text-only native ad in logical pixels.
const double kTextNativeAdHeight = 40.0;

/// A widget that displays a text-only native ad.
///
/// Shows a placeholder with rotating text while the ad is loading.
class TextNativeAdWidget extends StatefulWidget {
  const TextNativeAdWidget({
    super.key,
    required this.adUnitId,
    this.placeholderTexts,
    this.backgroundColor = const Color(0xFF141414),
    this.height = kTextNativeAdHeight,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClicked,
  });

  /// The AdMob ad unit ID.
  final String adUnitId;

  /// Optional list of placeholder texts to show while loading.
  /// If not provided, defaults to a generic "Loading..." text.
  final List<String>? placeholderTexts;

  /// Background color of the ad container.
  final Color backgroundColor;

  /// Height of the ad widget.
  final double height;

  /// Called when the ad is successfully loaded.
  final VoidCallback? onAdLoaded;

  /// Called when the ad fails to load.
  final void Function(String error)? onAdFailedToLoad;

  /// Called when the ad is clicked.
  final VoidCallback? onAdClicked;

  @override
  State<TextNativeAdWidget> createState() => _TextNativeAdWidgetState();
}

class _TextNativeAdWidgetState extends State<TextNativeAdWidget> {
  TextNativeAd? _textNativeAd;
  bool _isAdLoaded = false;

  // Placeholder state
  int _placeholderIndex = 0;
  Timer? _placeholderTimer;

  static const _defaultPlaceholders = ['Loading...'];

  List<String> get _placeholders =>
      widget.placeholderTexts ?? _defaultPlaceholders;

  @override
  void initState() {
    super.initState();
    if (_isAvailable) {
      _loadAd();
      _startPlaceholderRotation();
    }
  }

  @override
  void dispose() {
    _placeholderTimer?.cancel();
    _textNativeAd?.dispose();
    super.dispose();
  }

  bool get _isAvailable {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  void _startPlaceholderRotation() {
    if (_placeholders.length <= 1) return;

    _placeholderIndex = Random().nextInt(_placeholders.length);
    _placeholderTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_isAdLoaded && mounted) {
        setState(() {
          _placeholderIndex = (_placeholderIndex + 1) % _placeholders.length;
        });
      }
    });
  }

  void _loadAd() {
    _textNativeAd = TextNativeAd(
      adUnitId: widget.adUnitId,
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() => _isAdLoaded = true);
          widget.onAdLoaded?.call();
        }
      },
      onAdFailedToLoad: (ad, error) {
        widget.onAdFailedToLoad?.call(error.message);
      },
      onAdClicked: (ad) {
        widget.onAdClicked?.call();
      },
    );

    _textNativeAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable) {
      return const SizedBox.shrink();
    }

    return Container(
      height: widget.height,
      color: widget.backgroundColor,
      child: _isAdLoaded && _textNativeAd?.nativeAd != null
          ? AdWidget(ad: _textNativeAd!.nativeAd!)
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "Ad" badge placeholder
          Container(
            width: 28,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Ad',
              style: TextStyle(
                fontSize: 9,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Rotating placeholder text with max width
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _placeholders[_placeholderIndex],
                key: ValueKey(_placeholderIndex),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                  fontStyle: FontStyle.italic,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A positioned overlay for placing the ad at the bottom of a Stack.
///
/// Automatically accounts for safe area (navigation bar) on Android/iOS.
class TextNativeAdOverlay extends StatelessWidget {
  const TextNativeAdOverlay({
    super.key,
    required this.adUnitId,
    this.placeholderTexts,
    this.backgroundColor = const Color(0xFF141414),
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClicked,
  });

  final String adUnitId;
  final List<String>? placeholderTexts;
  final Color backgroundColor;
  final VoidCallback? onAdLoaded;
  final void Function(String error)? onAdFailedToLoad;
  final VoidCallback? onAdClicked;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return const SizedBox.shrink();
    }

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomPadding,
      child: TextNativeAdWidget(
        adUnitId: adUnitId,
        placeholderTexts: placeholderTexts,
        backgroundColor: backgroundColor,
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdClicked: onAdClicked,
      ),
    );
  }
}
