Pod::Spec.new do |s|
    
    s.platform = :ios
    s.ios.deployment_target = '13.0'
    s.requires_arc = true
    s.swift_version = "5"
    
    s.name             = 'iOSPhoneLib'
    s.version          = '0.1.1'
    s.summary          = 'Allow for easy implementation of SIP into a swift project.'

    s.description      = 'This library is an opinionated sip-wrapper, currently using Linphone as the base.'

    s.homepage         = 'https://gitlab.wearespindle.com/vialer/mobile/voip/ios-phone-lib'
    s.license          = { :type => 'AGPL', :file => 'LICENSE' }
    s.author           = { "Chris Kontos" => "chris.kontos@wearespindle.com" }
    s.source           = { :git => 'https://gitlab.wearespindle.com/vialer/mobile/voip/ios-phone-lib.git', :tag => s.version.to_s }
    s.source_files = 'iOSPhoneLib/**/*'

    s.dependency 'linphone-sdk-novideo', '5.2.112'
    s.framework = "UIKit"
    s.dependency 'Swinject', '~> 2.8.2'
  
end
