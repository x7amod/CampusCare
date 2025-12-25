//
//  RequestModel.swift
//  CampusCare
//
//  Created by BP-36-213-15 on 08/12/2025.
//


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
    let status:String
    let releaseDate:Timestamp
    let creatorID: String
    let creatorRole: String
    let assignedDate: Timestamp?
    let assignTechID: String
    // NEW FIELDS
    let inProgressDate: Timestamp?
    let completedDate: Timestamp?
    let lastUpdateDate: Timestamp?
    let deadline: Timestamp?
}

extension RequestModel {
    init?(from document: DocumentSnapshot) {
        let data = document.data() ?? [:]

        guard
            let category = data["category"] as? String,
            let description = data["description"] as? String,
            let imageURL = data["imageURL"] as? String,
            let location = data["location"] as? String,
            let priority = data["priority"] as? String,
            let title = data["title"] as? String,
            let status =  data["status"] as? String,
             let  releaseDate = data["releaseDate"] as? Timestamp,
                let creatorID = data["creatorID"] as? String,
            let creatorRole = data["creatorRole"] as? String,
            let assignTechID = data["assignTechID"] as? String
        else {
            return nil
        }
        
        let assignedDate = data["assignedDate"] as? Timestamp
        //
        let inProgressDate = data["inProgressDate"] as? Timestamp
        let completedDate = data["completedDate"] as? Timestamp
        let lastUpdateDate = data["lastUpdateDate"] as? Timestamp
        let deadline = data["deadline"] as? Timestamp
        


        self.id = document.documentID
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
        self.assignedDate = assignedDate
        self.assignTechID = assignTechID
        
        // ASSIGN NEW FIELDS
        self.inProgressDate = inProgressDate
        self.completedDate = completedDate
        self.lastUpdateDate = lastUpdateDate
        self.deadline = deadline

    }
}

