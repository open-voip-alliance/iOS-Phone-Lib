platform :ios, '13.0'
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

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end
