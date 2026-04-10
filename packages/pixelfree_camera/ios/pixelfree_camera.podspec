Pod::Spec.new do |s|
  s.name             = 'pixelfree_camera'
  s.version          = '0.0.1'
  s.summary          = 'Cross-platform beauty camera plugin scaffold.'
  s.description      = <<-DESC
Cross-platform beauty camera plugin scaffold for Flutter.
                       DESC
  s.homepage         = 'https://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'OpenAI' => 'support@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.swift_version = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
