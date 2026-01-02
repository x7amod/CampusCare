//
// AppDelegate.swift
// CampusCare
//

import UIKit
import FirebaseCore
import FirebaseAppCheck
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

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

// Request notification permissions
requestNotificationPermissions()

return true
}

// MARK: - Notification Permissions

private func requestNotificationPermissions() {
    let center = UNUserNotificationCenter.current()
    center.delegate = self
    
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            print("[AppDelegate] Notification permission error: \(error.localizedDescription)")
        } else {
            print("[AppDelegate] Notification permission granted: \(granted)")
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

// Show notifications even when app is in foreground
func userNotificationCenter(_ center: UNUserNotificationCenter,
                            willPresent notification: UNNotification,
                            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // Show banner play sound and update badge even when app is in foreground
    completionHandler([.banner, .sound, .badge])
}

// Handle notification tap by simply opening the app
func userNotificationCenter(_ center: UNUserNotificationCenter,
                            didReceive response: UNNotificationResponse,
                            withCompletionHandler completionHandler: @escaping () -> Void) {
    print("[AppDelegate] Notification tapped - opening app")
    // App will open to its current state
    completionHandler()
}

// MARK: UISceneSession Lifecycle
func application(_ application: UIApplication,
configurationForConnecting connectingSceneSession: UISceneSession,
options: UIScene.ConnectionOptions) -> UISceneConfiguration {
return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
}

func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }
}
