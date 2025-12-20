//
//  UserModel.swift
//  CampusCare
//
//  Created by BP-36-201-09 on 20/12/2025.
//


import Foundation
import FirebaseFirestore

struct UserModel {
    let id: String
    let username : String
    let role: String
}

extension UserModel {
    init?(from document: DocumentSnapshot) {
        let data = document.data() ?? [:]

        guard
            let username = data["username"] as? String,
            let role = data["role"] as? String
            
        else {
            return nil
        }

        self.id = document.documentID
        self.username = username
        self.role = role
    }
}
