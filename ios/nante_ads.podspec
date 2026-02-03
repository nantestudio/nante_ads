#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint nante_ads.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'nante_ads'
  s.version          = '0.0.1'
  s.summary          = 'Reusable text-only native ads for Flutter (AdMob).'
  s.description      = <<-DESC
Minimal 40dp single-line native ads for Flutter using Google AdMob.
Text-only format avoids MediaView size requirements while maintaining native ad CPM rates.
                       DESC
  s.homepage         = 'https://github.com/nantestudio/nante_ads'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Nante Studio' => 'contact@nantestudio.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'google_mobile_ads'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
