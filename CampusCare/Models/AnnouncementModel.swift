//
//  AnnouncementModel.swift
//  CampusCare
//
//  Created on 27/12/2025.
//

import Foundation
import FirebaseFirestore

struct AnnouncementModel: Comparable {
    let id: String
    let imageURL: String
    let isActive: Bool
    let priority: Int
    let createdAt: Timestamp
    
    // MARK: - Initializers
    
    init(id: String, imageURL: String, isActive: Bool, priority: Int, createdAt: Timestamp) {
        self.id = id
        self.imageURL = imageURL
        self.isActive = isActive
        self.priority = priority
        self.createdAt = createdAt
    }
    
    init?(from document: DocumentSnapshot) {
        guard let data = document.data(),
              let imageURL = data["imageURL"] as? String,
              let isActive = data["isActive"] as? Bool,
              let priority = data["priority"] as? Int,
              let createdAt = data["createdAt"] as? Timestamp else {
            return nil
        }
        
        self.id = document.documentID
        self.imageURL = imageURL
        self.isActive = isActive
        self.priority = priority
        self.createdAt = createdAt
    }
    
    // MARK: - Firestore Conversion
    
    func toDictionary() -> [String: Any] {
        return [
            "imageURL": imageURL,
            "isActive": isActive,
            "priority": priority,
            "createdAt": createdAt
        ]
    }
    
    // MARK: - Comparable
    
    static func < (lhs: AnnouncementModel, rhs: AnnouncementModel) -> Bool {
        // Lower priority number = higher priority (1 comes before 2)
        return lhs.priority < rhs.priority
    }
    
    static func == (lhs: AnnouncementModel, rhs: AnnouncementModel) -> Bool {
        return lhs.id == rhs.id
    }
}
