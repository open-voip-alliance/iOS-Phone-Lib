Pod::Spec.new do |s|
    
    s.name             = 'iOSVoIPLib'
    s.version          = '0.1.1'
    s.summary          = 'Allow for easy implementation of SIP into a swift project.'

    s.description      = 'This library is an opinionated sip-wrapper, currently using Linphone as the base.'

    s.homepage         = 'https://gitlab.wearespindle.com/vialer/mobile/voip/ios-phone-lib'
    s.license          = { :type => 'AGPL', :file => 'LICENSE' }
    s.author           = { 'jeremynorman89' => 'jeremy.norman@wearespindle.com' }
    s.source           = { :git => 'https://gitlab.wearespindle.com/vialer/mobile/voip/ios-phone-lib.git', :tag => s.version.to_s }

    s.ios.deployment_target = '11.3'

    s.source_files = 'iOSVoIPLib/Classes/**/*'

    s.dependency 'linphone-sdk', '5.1.10'
  
end
