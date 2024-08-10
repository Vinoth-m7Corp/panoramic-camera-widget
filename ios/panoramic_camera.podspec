#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint panoramic_camera.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'panoramic_camera'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*.{h,m,mm,cpp}'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'
  s.vendored_libraries = 'Classes/libDMD.a'
  s.frameworks = ['AVFoundation', 'CoreBluetooth', 'MobileCoreServices', 'Accelerate', 'Photos', 'CoreLocation', 'CoreMotion', 'AssetsLibrary']
  s.xcconfig = {
    'CLANG_CXX_LIBRARY' => 'libc++',
    'CLANG_ENABLE_MODULES' => 'YES',
    'OTHER_LDFLAGS' => '-lc++'
  }

end
