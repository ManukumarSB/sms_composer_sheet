#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sms_composer_sheet.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'sms_composer_sheet'
  s.version          = '1.0.0'
  s.summary          = 'A Flutter plugin that provides SMS composer with bottom sheet UI for iOS and Android'
  s.description      = <<-DESC
SMS Composer Sheet provides a unified interface for SMS composition with bottom sheet UI 
on both iOS and Android platforms. Uses native MFMessageComposeViewController on iOS 
and SMS intents on Android for optimal user experience.
                       DESC
  s.homepage         = 'https://github.com/manukumarsb/sms_composer_sheet'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Manukumar S B' => 'manubalarama@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'sms_composer_sheet_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
