platform :ios, '11.3'
inhibit_all_warnings!
use_frameworks!

source 'https://gitlab.linphone.org/BC/public/podspec.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'iOSPhoneLib' do
  pod 'Swinject'
  pod 'linphone-sdk-novideo', '5.2.43'
end

target 'Phone Lib Example' do
  pod 'iOSPhoneLib', :path => 'iOSPhoneLib.podspec'
  pod 'SAMKeychain'
  pod 'QuickTableViewController'
  pod 'Alamofire', '~> 5.2'
end
