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
    // Show banner, play sound, and update badge even when app is in foreground
    completionHandler([.banner, .sound, .badge])
}

// Handle notification tap
func userNotificationCenter(_ center: UNUserNotificationCenter,
                            didReceive response: UNNotificationResponse,
                            withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    print("[AppDelegate] Notification tapped with userInfo: \(userInfo)")
    // TODO: Navigate to specific screen based on notification type/requestID if needed
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
