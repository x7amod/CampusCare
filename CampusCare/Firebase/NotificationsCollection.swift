//
//  NotificationsCollection.swift
//  CampusCare
//
//  Created by m1 on 26/12/2025.
//

import Foundation
import FirebaseFirestore
import UserNotifications
import UIKit

final class NotificationsCollection {
    private let notificationsCollectionRef = FirestoreManager.shared.db.collection("Notification")
    
    // MARK: - Fetch Notifications
    
    /// Fetch all notifications for the logged-in user and trigger system notifications for new ones
    /// - Parameters:
    ///   - userID: The ID of the logged-in user
    ///   - completion: Result with array of NotificationModel or Error
    func fetchNotifications(for userID: String, completion: @escaping (Result<[NotificationModel], Error>) -> Void) {
        notificationsCollectionRef
            .whereField("userID", isEqualTo: userID)
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let notifications = documents.compactMap { NotificationModel(from: $0) }
                
                // Trigger system notifications for new ones
                self?.triggerSystemNotificationsForNew(notifications)
                
                // Update badge count
                self?.updateBadgeCount(for: userID)
                
                completion(.success(notifications))
            }
    }
    
    /// Fetch unread notifications count for the logged-in user
    /// - Parameters:
    ///   - userID: The ID of the logged-in user
    ///   - completion: Result with count of unread notifications or Error
    func fetchUnreadCount(for userID: String, completion: @escaping (Result<Int, Error>) -> Void) {
        notificationsCollectionRef
            .whereField("userID", isEqualTo: userID)
            .whereField("isRead", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let count = snapshot?.documents.count ?? 0
                completion(.success(count))
            }
    }
    
    // MARK: - Real-time Listener
    
    /// Listen to real-time updates for notifications
    /// - Parameters:
    ///   - userID: The ID of the logged-in user
    ///   - onChange: Callback with updated array of NotificationModel
    /// - Returns: ListenerRegistration to remove listener later
    func listenToNotifications(for userID: String, onChange: @escaping ([NotificationModel]) -> Void) -> ListenerRegistration {
        return notificationsCollectionRef
            .whereField("userID", isEqualTo: userID)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    onChange([])
                    return
                }
                
                let notifications = documents.compactMap { NotificationModel(from: $0) }
                onChange(notifications)
            }
    }
    
    // MARK: - Mark as Read
    
    /// Mark a notification as read
    /// - Parameters:
    ///   - notificationID: The ID of the notification
    ///   - completion: Result with success or Error
    func markAsRead(notificationID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        notificationsCollectionRef.document(notificationID).updateData([
            "isRead": true
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Mark all notifications as read for a user
    /// - Parameters:
    ///   - userID: The ID of the logged-in user
    ///   - completion: Result with success or Error
    func markAllAsRead(for userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        notificationsCollectionRef
            .whereField("userID", isEqualTo: userID)
            .whereField("isRead", isEqualTo: false)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success(()))
                    return
                }
                
                let batch = FirestoreManager.shared.db.batch()
                documents.forEach { document in
                    batch.updateData(["isRead": true], forDocument: document.reference)
                }
                
                batch.commit { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
    }
    
    // MARK: - Delete Notification
    
    /// Delete a notification
    /// - Parameters:
    ///   - notificationID: The ID of the notification to delete
    ///   - completion: Result with success or Error
    func deleteNotification(notificationID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        notificationsCollectionRef.document(notificationID).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Create Notification (Helper for testing or admin)
    
    /// Create a new notification
    /// - Parameters:
    ///   - notification: NotificationModel to create
    ///   - completion: Result with success or Error
    func createNotification(_ notification: NotificationModel, completion: @escaping (Result<Void, Error>) -> Void) {
        notificationsCollectionRef.document(notification.id).setData(notification.toDictionary()) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Simplified method to create a notification
    /// - Parameters:
    ///   - userID: The ID of the user who will receive the notification
    ///   - title: Notification title
    ///   - body: Notification body text
    ///   - type: Notification type (e.g., "New", "Assigned", "In-Progress", "Complete")
    ///   - requestID: The ID of the related request
    ///   - completion: Result with success or Error
    func createNotification(
        userID: String,
        title: String,
        body: String,
        type: String,
        requestID: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let notificationData: [String: Any] = [
            "userID": userID,
            "title": title,
            "body": body,
            "type": type,
            "requestID": requestID,
            "createdAt": Timestamp(date: Date()),
            "isRead": false
        ]
        
        notificationsCollectionRef.addDocument(data: notificationData) { error in
            if let error = error {
                print("[NotificationsCollection] Error creating notification: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("[NotificationsCollection] ✅ Notification created successfully")
                completion(.success(()))
            }
        }
    }
    
    // MARK: - System Notification Helpers
    
    /// Trigger system notifications for notifications that haven't been shown before
    /// - Parameter notifications: Array of notifications fetched from Firestore
    private func triggerSystemNotificationsForNew(_ notifications: [NotificationModel]) {
        // Check if notifications are enabled
        guard UserStore.shared.notificationsEnabled else {
            print("[NotificationsCollection] System notifications disabled by user")
            return
        }
        
        // Get current notification IDs for cleanup
        let currentIDs = Set(notifications.map { $0.id })
        
        // Clean up old IDs that are no longer in Firestore
        UserStore.shared.clearOldNotificationIDs(keeping: currentIDs)
        
        // Find new notifications that haven't been shown
        for notification in notifications {
            if !UserStore.shared.hasReceivedNotification(id: notification.id) {
                // This is a new notification, trigger system notification
                triggerLocalNotification(for: notification)
                
                // Mark as received
                UserStore.shared.markNotificationAsReceived(id: notification.id)
            }
        }
    }
    
    /// Trigger a local system notification
    /// - Parameter notification: The notification model to display
    private func triggerLocalNotification(for notification: NotificationModel) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = .default
        content.userInfo = [
            "notificationID": notification.id,
            "requestID": notification.requestID,
            "type": notification.type
        ]
        
        // Create request with unique identifier
        let request = UNNotificationRequest(
            identifier: notification.id,
            content: content,
            trigger: nil // Deliver immediately
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationsCollection] Failed to trigger system notification: \(error.localizedDescription)")
            } else {
                print("[NotificationsCollection] ✅ System notification triggered for: \(notification.title)")
            }
        }
    }
    
    /// Update the app badge count with unread notifications count
    /// - Parameter userID: The ID of the logged-in user
    func updateBadgeCount(for userID: String) {
        fetchUnreadCount(for: userID) { result in
            switch result {
            case .success(let count):
                DispatchQueue.main.async {
                    UNUserNotificationCenter.current().setBadgeCount(count, withCompletionHandler: nil)
                    print("[NotificationsCollection] Badge count updated to: \(count)")
                }
            case .failure(let error):
                print("[NotificationsCollection] Failed to update badge count: \(error.localizedDescription)")
            }
        }
    }
    
    /// Clear the app badge count (call when user views all notifications)
    func clearBadgeCount() {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().setBadgeCount(0, withCompletionHandler: nil)
        }
    }
}

