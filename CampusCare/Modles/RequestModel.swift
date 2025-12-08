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
            let title = data["title"] as? String
        else {
            return nil
        }

        self.id = document.documentID
        self.category = category
        self.description = description
        self.imageURL = imageURL
        self.location = location
        self.priority = priority
        self.title = title
    }
}
