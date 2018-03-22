#
# Be sure to run `pod lib lint SignalServiceKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SignalServiceKit"
  s.version          = "0.0.7"
  s.summary          = "An Objective-C library for communicating with the Signal messaging service."

  s.description      = <<-DESC
An Objective-C library for communicating with the Signal messaging service.
  DESC

  s.homepage         = "https://github.com/WhisperSystems/SignalServiceKit"
  s.license          = 'GPLv3'
  s.author           = { "Frederic Jacobs" => "github@fredericjacobs.com" }
  s.source           = { :git => "https://github.com/WhisperSystems/SignalServiceKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/FredericJacobs'

  s.platform     = :ios, '8.0'
  #s.ios.deployment_target = '8.0'
  #s.osx.deployment_target = '10.9'
  s.requires_arc = true
  s.source_files = 'src/**/*.{h,m,mm}'

  s.resource = 'src/Security/PinningCertificate/textsecure.cer'
  s.prefix_header_file = 'src/TSPrefix.h'
  s.xcconfig = { 'OTHER_CFLAGS' => '$(inherited) -DSQLITE_HAS_CODEC' }

  s.dependency '25519'
  s.dependency 'CocoaLumberjack'
  s.dependency 'AFNetworking', '= 3.1.0'
  s.dependency 'AxolotlKit'
  s.dependency 'Mantle', '= 2.0.7'
  s.dependency 'YapDatabase/SQLCipher', '= 2.9.1'
  # NOTE: we're using a custom fork of SocketRocket to support our certificate
  # pinning policy.
  # see Example/TSKitiOSTestApp/Podfile for details
  s.dependency 'SocketRocket'
  s.dependency 'libPhoneNumber-iOS', '= 0.8.15'
  s.dependency 'SSKeychain', '= 1.4.0'
  s.dependency 'TwistedOakCollapsingFutures'
end
