platform :ios, '11.3'
inhibit_all_warnings!
use_frameworks!

# https://github.com/BelledonneCommunications/linphone-sdk/issues/273
# https://github.com/CocoaPods/CocoaPods/issues/11737
install! 'cocoapods', :disable_input_output_paths => true

source 'https://gitlab.linphone.org/BC/public/podspec.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'iOSPhoneLib' do
  pod 'Swinject'
  pod 'linphone-sdk-novideo', '5.2.20'
end

target 'Phone Lib Example' do
  pod 'iOSPhoneLib', :path => 'iOSPhoneLib.podspec'
  pod 'SAMKeychain'
  pod 'QuickTableViewController'
  pod 'Alamofire', '~> 5.2'
end
