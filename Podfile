platform :ios, '13.0'
inhibit_all_warnings!
use_frameworks! :linkage => :static

source 'https://gitlab.linphone.org/BC/public/podspec.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'Phone Lib Example' do
  pod 'SAMKeychain'
  pod 'QuickTableViewController'
  pod 'Alamofire', '~> 5.9.1'
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
