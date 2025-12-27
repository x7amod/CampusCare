//
// AppDelegate.swift
// CampusCare
//

import UIKit
import FirebaseCore
import FirebaseAppCheck //Added this import - Malak

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

func application(_ application: UIApplication,
didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

FirebaseApp.configure()

// AppCheck setup for simulator
#if targetEnvironment(simulator)
AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
print("AppCheck Debug provider enabled for simulator")
#endif

// Apply global navigation bar styling
NavigationBarStyleManager.shared.applyGlobalNavigationBarStyle()

return true
}

// MARK: UISceneSession Lifecycle
func application(_ application: UIApplication,
configurationForConnecting connectingSceneSession: UISceneSession,
options: UIScene.ConnectionOptions) -> UISceneConfiguration {
return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
}

func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }
}
