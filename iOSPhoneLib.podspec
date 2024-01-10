Pod::Spec.new do |s|
    
    s.platform = :ios
    s.ios.deployment_target = '13.0'
    s.requires_arc = true
    s.swift_version = "5"
    
    s.name             = 'iOSPhoneLib'
    s.version          = '0.1.2'
    s.summary          = 'Allow for easy implementation of SIP into a swift project.'

    s.description      = 'This library is an opinionated sip-wrapper, currently using Linphone as the base.'
    s.static_framework = true
    s.homepage         = 'https://github.com/open-voip-alliance/iOS-Phone-Lib'
    s.license          = { :type => 'AGPL', :file => 'LICENSE' }
    s.author           = { "Johannes Nevels" => "johannes.nevels@voys.nl" }
    s.source           = { :git => 'https://github.com/open-voip-alliance/iOS-Phone-Lib.git', :tag => s.version.to_s }
    s.source_files = 'iOSPhoneLib/**/*'
    
    s.vendored_frameworks = 'linphone-sdk-novideo-frameworks/*'
    s.framework = 'UIKit'
    s.dependency 'Swinject', '~> 2.8.2'
  
end
