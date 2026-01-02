//
//  UserStore.swift
//  CampusCare
//
//  Created by Reem on 23/12/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserStore {
    static let shared = UserStore()
    private init() {}
    
    var currentUserID: String?
    var currentUserRole: String?
    var currentUsername: String?
    var currentTechID: String?
    
    // MARK: - Notification Preferences (persisted in UserDefaults)
    
    private let notificationsEnabledKey = "notificationsEnabled"
    private let receivedNotificationIDsKey = "receivedNotificationIDs"
    
    /// Whether system notifications are enabled (default: true)
    var notificationsEnabled: Bool {
        get {
            // Default to true if not set
            if UserDefaults.standard.object(forKey: notificationsEnabledKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: notificationsEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: notificationsEnabledKey)
        }
    }
    
    /// Set of notification IDs that have already triggered a system notification
    var receivedNotificationIDs: Set<String> {
        get {
            let array = UserDefaults.standard.stringArray(forKey: receivedNotificationIDsKey) ?? []
            return Set(array)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: receivedNotificationIDsKey)
        }
    }
    
    /// Check if a notification has already been received
    func hasReceivedNotification(id: String) -> Bool {
        return receivedNotificationIDs.contains(id)
    }
    
    /// Mark a notification as received
    func markNotificationAsReceived(id: String) {
        var ids = receivedNotificationIDs
        ids.insert(id)
        receivedNotificationIDs = ids
    }
    
    /// Clear old notification IDs (call periodically to prevent unbounded growth)
    func clearOldNotificationIDs(keeping recentIDs: Set<String>) {
        receivedNotificationIDs = receivedNotificationIDs.intersection(recentIDs)
    }
}
