Pod::Spec.new do |s|
    
    s.platform = :ios
    s.ios.deployment_target = '12.0'
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

    s.ios.deployment_target = '11.3'

    s.source_files = 'iOSPhoneLib/**/*'

    s.dependency 'linphone-sdk', '5.1.28'
    s.framework = "UIKit"
    s.dependency 'Swinject', '~> 2.7.1'
    s.resource_bundles = { 'Resources' => ['iOSPhoneLib/iOSVoIPLib/Resources'] }
  
end
