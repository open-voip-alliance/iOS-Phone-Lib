platform :ios, '11.3'
inhibit_all_warnings!
use_frameworks!

source 'https://gitlab.linphone.org/BC/public/podspec.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'iOS Phone Lib' do
  pod 'iOSVoIPLib', :path => 'iOSVoIPLib.podspec'
  pod 'Swinject'
  pod 'linphone-sdk', '5.0.70'

  target 'VoIPLibTests' do
    inherit! :search_paths
  end
end

target 'Phone Lib Example' do
  pod 'PIL', :path => 'PIL.podspec'
  pod 'SAMKeychain'
  pod 'QuickTableViewController'
  pod 'Alamofire', '~> 5.2'
end
