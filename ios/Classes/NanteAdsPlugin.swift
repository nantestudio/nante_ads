import Flutter
import UIKit
import google_mobile_ads

/// Factory ID for text-only native ads. Must match Dart constant.
let kNanteTextOnlyFactoryId = "nanteTextOnly"

public class NanteAdsPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Register the text-only native ad factory
        let factory = TextOnlyNativeAdFactory()
        FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
            registrar,
            factoryId: kNanteTextOnlyFactoryId,
            nativeAdFactory: factory
        )
    }
}

/// Text-only native ad factory for minimal single-line ads.
///
/// Uses only the headline text - no MediaView - to avoid video size
/// requirements while maintaining native ad CPM rates.
class TextOnlyNativeAdFactory: NSObject, FLTNativeAdFactory {
    func createNativeAd(
        _ nativeAd: GADNativeAd,
        customOptions: [AnyHashable: Any]? = nil
    ) -> GADNativeAdView? {
        let nativeAdView = GADNativeAdView()
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.0)

        // Horizontal stack for content
        let contentStack = UIStackView()
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = 10
        nativeAdView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 12),
            contentStack.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -12),
            contentStack.topAnchor.constraint(equalTo: nativeAdView.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor),
        ])

        // "Ad" badge
        let adBadge = UILabel()
        adBadge.translatesAutoresizingMaskIntoConstraints = false
        adBadge.text = "Ad"
        adBadge.font = UIFont.systemFont(ofSize: 9, weight: .medium)
        adBadge.textColor = UIColor.white.withAlphaComponent(0.7)
        adBadge.textAlignment = .center
        adBadge.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        adBadge.layer.cornerRadius = 4
        adBadge.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            adBadge.widthAnchor.constraint(equalToConstant: 28),
            adBadge.heightAnchor.constraint(equalToConstant: 18),
        ])
        contentStack.addArrangedSubview(adBadge)

        // Headline only - no MediaView
        let headlineLabel = UILabel()
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.text = nativeAd.headline
        headlineLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        headlineLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        headlineLabel.numberOfLines = 1
        headlineLabel.lineBreakMode = .byTruncatingTail
        contentStack.addArrangedSubview(headlineLabel)
        nativeAdView.headlineView = headlineLabel

        nativeAdView.nativeAd = nativeAd
        return nativeAdView
    }
}
