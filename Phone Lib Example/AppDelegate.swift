//
//  AppDelegate.swift
//  PhoneLibExample
//
//  Created by Chris Kontos on 08/01/2021.
//

import UIKit
import iOSPhoneLib

@main
class AppDelegate: UIResponder, UIApplicationDelegate, LogDelegate {
    

    var window: UIWindow?
    
    private let defaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        loadDefaultCredentialsFromEnvironment()
        
        let applicationSetup = ApplicationSetup(
            middleware: VoIPGRIDMiddleware(),
            requestCallUi: {
                if let nav = self.window?.rootViewController as? UITabBarController {
                    nav.performSegue(withIdentifier: "LaunchCallSegue", sender: nav)
                }
            },
            logDelegate: self
        )
        
        do {
            _ = try startIOSPIL(
                applicationSetup: applicationSetup,
                auth: Auth(
                    username: self.userDefault(key: "username"),
                    password: self.userDefault(key: "password"),
                    domain: self.userDefault(key: "domain"),
                    port: Int(self.userDefault(key: "port")) ?? 0,
                    secure: self.defaults.bool(forKey: "encryption")
                )
            )
        } catch {
            print("ERROR: Failed to start PIL - \(error)")
        }
        
        return true
    }
    
    /// Loads in environment variables into the user default, so you can provide default login information to avoid manually adding it every time.
    ///
    /// To add environment variables, in xCode, "Edit Scheme" > Run > Environment and add the environment keys (e.g. pil.default.username) and
    /// the relevant values (i.e. your voip account password).
    private func loadDefaultCredentialsFromEnvironment() {
        _ = loadCredentialFromEnvironment(environmentKey: "pil.default.username", userDefaultsKey: "username")
        _ = loadCredentialFromEnvironment(environmentKey: "pil.default.password", userDefaultsKey: "password")
        _ = loadCredentialFromEnvironment(environmentKey: "pil.default.domain", userDefaultsKey: "domain")
        _ = loadCredentialFromEnvironment(environmentKey: "pil.default.port", userDefaultsKey: "port")
        if loadCredentialFromEnvironment(environmentKey: "pil.default.voipgrid.username", userDefaultsKey: "voipgrid_username")
            && loadCredentialFromEnvironment(environmentKey: "pil.default.voipgrid.password", userDefaultsKey: "voipgrid_password") {
            SettingsViewController.attemptVoipgridLogin { _ in }
        }
    }
    
    /// Attempts to load a credential from an environment variable, and puts it into the user defaults.
    private func loadCredentialFromEnvironment(environmentKey: String, userDefaultsKey: String) -> Bool {
        if let value = ProcessInfo.processInfo.environment[environmentKey] {
            if !value.isEmpty {
                self.defaults.set(value, forKey: userDefaultsKey)
                return true
            } else {
                return false
            }
        }
        
        return false
    }
    
    private func userDefault(key: String) -> String {
        defaults.object(forKey: key) as? String ?? ""
    } //TODO: move this outside ViewControllers
    
    func onLogReceived(message: String, level: LogLevel) {
        print("\(String(describing: level)) \(message)")
    }
}

