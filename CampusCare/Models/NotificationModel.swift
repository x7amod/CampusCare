//
//  NotificationModel.swift
//  CampusCare
//
//  Created by m1 on 26/12/2025.
//

import Foundation
import FirebaseFirestore

/// Model representing a notification in the system.
/// Matches Firestore structure: body, createdAt, isRead, requestID, title, type, userID
struct NotificationModel {
    let id: String
    let title: String
    let body: String
    let createdAt: Timestamp
    let isRead: Bool
    let userID: String
    let type: String
    let requestID: String
    
    /// Initialize from Firestore document
    init?(from document: DocumentSnapshot) {
        guard let data = document.data(),
              let title = data["title"] as? String,
              let body = data["body"] as? String,
              let createdAt = data["createdAt"] as? Timestamp,
              let userID = data["userID"] as? String,
              let type = data["type"] as? String,
              let requestID = data["requestID"] as? String else {
            return nil
        }
        
        self.id = document.documentID
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.isRead = data["isRead"] as? Bool ?? false
        self.userID = userID
        self.type = type
        self.requestID = requestID
    }
    
    /// Initialize with explicit values (for testing or manual creation)
    init(
        id: String,
        title: String,
        body: String,
        createdAt: Timestamp,
        isRead: Bool,
        userID: String,
        type: String,
        requestID: String
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.isRead = isRead
        self.userID = userID
        self.type = type
        self.requestID = requestID
    }
    
    /// Convert to dictionary for Firestore
    func toDictionary() -> [String: Any] {
        return [
            "title": title,
            "body": body,
            "createdAt": createdAt,
            "isRead": isRead,
            "userID": userID,
            "type": type,
            "requestID": requestID
        ]
    }
}
