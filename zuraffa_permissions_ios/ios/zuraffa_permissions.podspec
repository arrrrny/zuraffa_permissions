#
# ZuraffaPermissions iOS/macOS podspec — the shared native plugin.
#
Pod::Spec.new do |s|
  s.name             = 'zuraffa_permissions'
  s.version          = '0.1.0'
  s.summary          = 'The iOS/macOS implementation of zuraffa_permissions.'
  s.description      = 'Real permission requests: camera, photos, notifications, location, microphone, contacts, calendar, biometrics.'
  s.homepage         = 'https://zuraffa.com'
  s.license          = { :type => 'Apache-2.0', :file => '../LICENSE' }
  s.author           = { 'Zuraffa' => 'https://github.com/arrrrny' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '13.0'
  s.swift_version    = '5.9'
end
