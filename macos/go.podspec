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
  s.public_header_files = 'Classes/**/*.h'
  s.source_files = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.vendored_libraries  = 'libgocoresdk.dylib'
  s.static_framework = false
  s.libraries = 'resolv'
  # s.user_target_xcconfig = { 'ENABLE_BITCODE' => 'NO', 'EXPANDED_CODE_SIGN_IDENTITY' => '', 'CODE_SIGNING_REQUIRED' => 'NO', 'CODE_SIGNING_ALLOWED' => 'NO' }
  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
