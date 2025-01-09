#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint go.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'go'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = ['Classes/**/*.h']
  s.vendored_frameworks = 'libgocoresdk.xcframework'
  s.static_framework = false
  # s.user_target_xcconfig = { 'ENABLE_BITCODE' => 'NO', 'EXPANDED_CODE_SIGN_IDENTITY' => '', 'CODE_SIGNING_REQUIRED' => 'NO', 'CODE_SIGNING_ALLOWED' => 'NO' }
  s.libraries = 'resolv'

  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'



end
