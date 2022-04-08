platform :ios, '11.3'
inhibit_all_warnings!
use_frameworks!

source 'https://gitlab.linphone.org/BC/public/podspec.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'VoIPLib' do
  pod 'linphone-sdk-novideo', '5.1.15'

  target 'VoIPLibTests' do
    inherit! :search_paths
  end
end

target 'PIL' do
  pod 'iOSVoIPLib', :path => 'iOSVoIPLib.podspec'
  pod 'Swinject'
  
  target 'PILTests' do
    inherit! :search_paths
  end
end
  
target 'Phone Lib Example' do
  pod 'PIL', :path => 'PIL.podspec'
  pod 'SAMKeychain'
  pod 'QuickTableViewController'
  pod 'Alamofire', '~> 5.2'
end
