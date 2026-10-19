# Packaging-only pod: vendors the prebuilt dynamic spcore.xcframework (universal arm64+x86_64
# spcore.framework) produced by native/scripts/build_spcore.sh macos. CocoaPods embeds and
# code-signs it into <App>.app/Contents/Frameworks, so DynamicLibrary.open('spcore.framework/spcore') works.
Pod::Spec.new do |s|
  s.name             = 'spcore_flutter'
  s.version          = '1.0.0'
  s.summary          = 'Prebuilt SoftphonePro SIP engine (spcore).'
  s.description      = 'Bundles spcore.xcframework (PJSIP-based SIP engine).'
  s.homepage         = 'https://github.com/softphonepro/softphonepro'
  s.license          = { :type => 'GPL-3.0-or-later', :file => '../LICENSE' }
  s.author           = { 'SoftphonePro' => 'noreply@softphonepro.invalid' }
  s.source           = { :path => '.' }
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '11.0'
  s.vendored_frameworks = 'Frameworks/spcore.xcframework'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
