# iOSPhoneLib

## Introduction

This project contains the framework and a sample project for **iOSPhoneLib**. Both rely fully and only on **Swift Package Manager (SPM)**.

## Project Structure with SPM

There are two `Package.swift` files containing references to Linphone:

1. **Internal framework package:**  
   Located at `LinphoneWrapper/Package.swift`.  
   This allows you to run the `iOSPhoneLib` scheme and continue developing the framework without needing to run the example app.

2. **External package:**  
   Located at `Package.swift`.  
   This package is used by the example app to resemble how a real app would consume the library.

### Issues resolved to get SPM working

- **Module vs. Type Name Collision:**  
  The `linphonesw` name is used both as a module and as a struct inside the library, causing ambiguity.  
  To fix this, a wrapper with typealiases was created inside:

      LinphoneWrapper/Sources/LinphoneTypes

- **Conditional Imports:**  
  Depending on build configuration, the following import pattern is used to resolve the correct module:

      #if IOSPHONELIB_PRIVATE
      import iOSPhoneLib_Private
      #else
      import LinphoneWrapper
      #endif

- **Swinject Fork:**  
  We forked [Swinject](https://github.com/Swinject/Swinject) to fix [this issue](https://github.com/Swinject/Swinject/issues/572) where Xcode automatically adds the dynamic version of Swinject.  
  We plan to migrate to a better alternative in the future.

---

## Updating Packages

### Updating the Linphone SDK

To update the Linphone SDK version used in the project, do the following:

1. Update the `.package` reference in **both** these files and don't forget to press save:
   - `LinphoneWrapper/Package.swift`
   - `Package.swift`

   For example, to update to version `5.4.24`:

      .package(url: "https://gitlab.linphone.org/BC/public/linphone-sdk-swift-ios.git", .exact("5.4.24"))

2. Open the workspace in Xcode, go to:  
   **File > Packages > Update to Latest Package Versions**
   
   You should see in the bottom-left of Xcode, in the Package Dependencies pane, the version change reflected afterwards.

3. Build the `iOSPhoneLib` scheme to verify it compiles successfully.  
   If the new Linphone version introduces breaking changes, apply necessary fixes.

4. Run the example app (`Phone Lib Example`) to verify that the integration works correctly.

5. Commit your changes and create a new git tag based on the previous tag to mark the update. This tag can then be referenced to install this specific version of the package.
