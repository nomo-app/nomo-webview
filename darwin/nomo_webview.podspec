#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint test_plugin1.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
    s.name             = 'nomo_webview'
    s.version          = '0.0.1'
    s.summary          = 'An expansion on webview_flutter plugin'
    s.description      = <<-DESC
    An expansion on webview_flutter plugin.
                         DESC
    s.homepage         = 'https://github.com/nomo-app/nomo-webview'
    s.license          = { :file => '../LICENSE' }
    s.author           = { 'Nomo' => 'dev2@nomo.app' }
    s.source           = { :path => '.' }
    s.source_files = 'Classes/**/*'
    s.dependency 'webview_flutter_wkwebview'
    s.dependency 'Flutter'
    s.platform = :ios, '12.0'
  
    # Flutter.framework does not contain a i386 slice.
    s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES'} #, 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
    s.swift_version = '5.0'
  
    # If your plugin requires a privacy manifest, for example if it uses any
    # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
    # plugin's privacy impact, and then uncomment this line. For more information,
    # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
    # s.resource_bundles = {'test_plugin1_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
  end
  
