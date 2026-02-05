import Flutter
import UIKit
import google_mobile_ads

/// Factory ID for text-only native ads. Must match Dart constant.
public let kNanteTextOnlyFactoryId = "nanteTextOnly"

/// Height of the native ad view in points. Must match Dart kTextNativeAdHeight.
private let kAdHeight: CGFloat = 40.0

public class NanteAdsPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        // iOS requires the app to call registerFactory() from AppDelegate
        // because registerNativeAdFactory needs FlutterPluginRegistry, not FlutterPluginRegistrar
    }

    /// Call this from your AppDelegate's didFinishLaunchingWithOptions
    /// after GeneratedPluginRegistrant.register(with: self)
    ///
    /// Example:
    /// ```swift
    /// NanteAdsPlugin.registerFactory(registry: self)
    /// ```
    @objc public static func registerFactory(registry: FlutterPluginRegistry) {
        let factory = TextOnlyNativeAdFactory()
        FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
            registry,
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

        // Set explicit height constraint for the ad view
        nativeAdView.heightAnchor.constraint(equalToConstant: kAdHeight).isActive = true

        // Horizontal stack for content - centered vertically
        let contentStack = UIStackView()
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = 16
        nativeAdView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: nativeAdView.centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: nativeAdView.centerYAnchor),
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

        // Headline only - no MediaView, with marquee for long text
        let headlineLabel = MarqueeLabel()
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.text = nativeAd.headline
        headlineLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        headlineLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        headlineLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 280).isActive = true
        contentStack.addArrangedSubview(headlineLabel)
        nativeAdView.headlineView = headlineLabel

        // Start marquee animation after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            headlineLabel.startScrolling()
        }

        nativeAdView.nativeAd = nativeAd
        return nativeAdView
    }
}

/// A UILabel subclass that scrolls text horizontally if it overflows.
class MarqueeLabel: UILabel {
    private var scrollTimer: Timer?
    private var scrollOffset: CGFloat = 0
    private let scrollSpeed: CGFloat = 30 // points per second
    private let pauseDuration: TimeInterval = 2.0
    private var textWidth: CGFloat = 0
    private var isPaused = true

    override var text: String? {
        didSet {
            textWidth = intrinsicContentSize.width
            scrollOffset = 0
            isPaused = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textWidth = intrinsicContentSize.width
    }

    func startScrolling() {
        guard textWidth > bounds.width else { return }
        scrollTimer?.invalidate()
        scrollOffset = 0
        isPaused = true

        // Pause before starting
        DispatchQueue.main.asyncAfter(deadline: .now() + pauseDuration) { [weak self] in
            self?.isPaused = false
            self?.scrollTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
                self?.updateScroll()
            }
        }
    }

    private func updateScroll() {
        guard !isPaused, textWidth > bounds.width else { return }

        scrollOffset += scrollSpeed / 60.0
        let maxScroll = textWidth - bounds.width + 20 // 20pt extra padding

        if scrollOffset >= maxScroll {
            // Pause at the end, then reset
            isPaused = true
            DispatchQueue.main.asyncAfter(deadline: .now() + pauseDuration) { [weak self] in
                self?.scrollOffset = 0
                self?.setNeedsDisplay()
                DispatchQueue.main.asyncAfter(deadline: .now() + self!.pauseDuration) { [weak self] in
                    self?.isPaused = false
                }
            }
        }
        setNeedsDisplay()
    }

    override func drawText(in rect: CGRect) {
        var adjustedRect = rect
        adjustedRect.origin.x -= scrollOffset
        adjustedRect.size.width = textWidth
        super.drawText(in: adjustedRect)
    }

    deinit {
        scrollTimer?.invalidate()
    }
}
