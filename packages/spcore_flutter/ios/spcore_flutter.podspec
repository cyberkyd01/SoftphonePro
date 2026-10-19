# Packaging-only pod: vendors the prebuilt dynamic spcore.xcframework produced by
# native/scripts/build_spcore.sh ios (device arm64 + simulator arm64/x86_64).
Pod::Spec.new do |s|
  s.name             = 'spcore_flutter'
  s.version          = '1.0.0'
  s.summary          = 'Prebuilt SoftphonePro SIP engine (spcore).'
  s.description      = 'Bundles spcore.xcframework (PJSIP-based SIP engine).'
  s.homepage         = 'https://github.com/softphonepro/softphonepro'
  s.license          = { :type => 'GPL-3.0-or-later', :file => '../LICENSE' }
  s.author           = { 'SoftphonePro' => 'noreply@softphonepro.invalid' }
  s.source           = { :path => '.' }
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.vendored_frameworks = 'Frameworks/spcore.xcframework'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
