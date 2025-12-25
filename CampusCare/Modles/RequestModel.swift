import Foundation
import FirebaseFirestore

struct RequestModel {
    let id: String
    let category: String
    let description: String
    let imageURL: String
    let location: String
    let priority: String
    let title: String
    let status: String
    let releaseDate: Timestamp
    let creatorID: String
    let creatorRole: String
    let assignedDate: Timestamp?
    let assignTechID: String
    let inProgressDate: Timestamp?
    let completedDate: Timestamp?
    let lastUpdateDate: Timestamp?
    
    //  Initializers
    
    // Initializer for DocumentSnapshot
    init?(from document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        self.init(id: document.documentID, data: data)
    }
    
    // Initializer for QueryDocumentSnapshot
    init?(from queryDocument: QueryDocumentSnapshot) {
        self.init(id: queryDocument.documentID, data: queryDocument.data())
    }
    
    // Convenience initializer for dictionary data
    private init?(id: String, data: [String: Any]) {
        guard
            let category = data["category"] as? String,
            let description = data["description"] as? String,
            let imageURL = data["imageURL"] as? String,
            let location = data["location"] as? String,
            let priority = data["priority"] as? String,
            let title = data["title"] as? String,
            let status = data["status"] as? String,
            let releaseDate = data["releaseDate"] as? Timestamp,
            let creatorID = data["creatorID"] as? String,
            let creatorRole = data["creatorRole"] as? String,
            let assignTechID = data["assignTechID"] as? String
        else {
            print("Failed to parse required fields for RequestModel")
            print("   Missing or invalid data in document ID: \(id)")
            print("   Data keys: \(data.keys)")
            return nil
        }
        
        self.id = id
        self.category = category
        self.description = description
        self.imageURL = imageURL
        self.location = location
        self.priority = priority
        self.title = title
        self.status = status
        self.releaseDate = releaseDate
        self.creatorID = creatorID
        self.creatorRole = creatorRole
        self.assignTechID = assignTechID
        
        // Optional fields
        self.assignedDate = data["assignedDate"] as? Timestamp
        self.inProgressDate = data["inProgressDate"] as? Timestamp
        self.completedDate = data["completedDate"] as? Timestamp
        self.lastUpdateDate = data["lastUpdateDate"] as? Timestamp
        
        // Debug print - FIXED: Use .formattedString instead of .toString()
        print("Created RequestModel: \(title) for tech: \(assignTechID)")
        if let assignedDate = self.assignedDate {
            print("   Assigned Date: \(assignedDate.dateValue().formattedString)")
        }
    }
}

// Added this for backward compatibility
extension RequestModel {
    // This allows both initializers to work
    init?(document: QueryDocumentSnapshot) {
        self.init(from: document)
    }
}
