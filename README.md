# nante_ads

Minimal 40dp single-line native ads for Flutter using Google AdMob.

## Features

- **Text-only native ads** - No MediaView, avoids video size requirements
- **40dp height** - Minimal footprint, perfect for bottom safe area
- **Auto-registration** - Plugin auto-registers native ad factory
- **Placeholder rotation** - Shows custom text while ad loads
- **Safe area support** - `TextNativeAdOverlay` for easy positioning

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  nante_ads:
    git:
      url: https://github.com/nantestudio/nante_ads.git
```

## Platform Setup

### Android

Add your AdMob App ID to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
    </application>
</manifest>
```

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
</array>
```

## Usage

### Basic Widget

```dart
import 'package:nante_ads/nante_ads.dart';

TextNativeAdWidget(
  adUnitId: 'ca-app-pub-xxx/yyy',
  placeholderTexts: ['Loading...', 'Fetching ad...'],
  onAdLoaded: () => print('Ad loaded'),
  onAdFailedToLoad: (error) => print('Failed: $error'),
)
```

### Overlay (for Stack positioning)

```dart
Stack(
  children: [
    // Your content
    TextNativeAdOverlay(
      adUnitId: 'ca-app-pub-xxx/yyy',
      placeholderTexts: ['Tip: Swipe to navigate'],
    ),
  ],
)
```

### Initialize AdMob SDK

Make sure to initialize the Mobile Ads SDK before using ads:

```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(MyApp());
}
```

## API Reference

### TextNativeAdWidget

| Parameter | Type | Description |
|-----------|------|-------------|
| `adUnitId` | `String` | Required. Your AdMob native ad unit ID |
| `placeholderTexts` | `List<String>?` | Optional. Rotating text shown while loading |
| `backgroundColor` | `Color` | Default: `Color(0xFF141414)` |
| `height` | `double` | Default: `40.0` |
| `onAdLoaded` | `VoidCallback?` | Called when ad loads successfully |
| `onAdFailedToLoad` | `Function(String)?` | Called with error message on failure |
| `onAdClicked` | `VoidCallback?` | Called when ad is clicked |

### TextNativeAdOverlay

Same parameters as `TextNativeAdWidget`, but wrapped in a `Positioned` widget that sits at the bottom of the screen above the safe area.

## License

MIT
