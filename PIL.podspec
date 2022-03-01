Pod::Spec.new do |s|

    s.platform = :ios
    s.ios.deployment_target = '11.3'
    s.name = "PIL"
    s.summary = "Platform integration layer uses Linphone through VoIPLib to provide SIP functionality."
    s.requires_arc = true

    s.version = "0.1.0"

    s.license = { :type => "MIT", :file => "LICENSE" }

    s.author = { "Chris Kontos" => "chris.kontos@wearespindle.com" }

    s.homepage = "https://gitlab.wearespindle.com/vialer/mobile/voip/ios-phone-lib"

    s.source = { :git => "https://gitlab.wearespindle.com/vialer/mobile/voip/ios-phone-lib.git",
                 :tag => "#{s.version}" }

    s.framework = "UIKit"
    s.dependency 'iOSVoIPLib', '~> 0.1.0'
    s.dependency 'Swinject', '~> 2.7.1'

    s.source_files = "PIL/**/*.{swift}"
    s.resources = "PIL/Resources/**"

    s.swift_version = "5"

end
