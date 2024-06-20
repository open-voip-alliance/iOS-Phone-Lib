# Remove current frameworks
rm -r linphone-sdk-novideo-frameworks/
# Copy existing depedencies of linphone to frameworks to be included in pod
cp -r Pods/linphone-sdk-novideo/linphone-sdk-novideo/apple-darwin/XCFrameworks/ linphone-sdk-novideo-frameworks/

# Export linphonesw for device
xcodebuild archive \
-workspace iOSPhoneLib.xcworkspace \
-scheme linphone-sdk-novideo \
-arch arm64 \
-configuration Release \
-sdk iphoneos \
-archivePath archives/ios_devices.xcarchive \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
SKIP_INSTALL=NO \

# Export linphonesw for simulator
xcodebuild archive \
-workspace iOSPhoneLib.xcworkspace \
-scheme linphone-sdk-novideo \
-arch x86_64 \
-configuration Debug \
-sdk iphonesimulator \
-archivePath archives/ios_simulators.xcarchive \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
SKIP_INSTALL=NO \

# Combine both linphonesw frameworks to XCFramework
xcodebuild \
-create-xcframework \
-framework archives/ios_devices.xcarchive/Products/Library/Frameworks/linphonesw.framework \
-framework archives/ios_simulators.xcarchive/Products/Library/Frameworks/linphonesw.framework \
-output linphone-sdk-novideo-frameworks/linphonesw.xcframework

# Remove archives
rm -rf archives

