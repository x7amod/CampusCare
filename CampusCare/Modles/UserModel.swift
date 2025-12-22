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
    let Role: String
    let FirstName: String
    let LastName: String
    let Department: String
}

extension UserModel {
    init?(from document: DocumentSnapshot) {
        let data = document.data() ?? [:]
        
        guard
            let username = data["Username"] as? String,
            let Role = data["Role"] as? String,
            let FirstName = data["First Name"] as? String,
            let LastName = data["Last Name"] as? String,
            let Department = data["Department"] as? String

        else {
            return nil
        }

        self.id = document.documentID
        self.username = username
        self.Role = Role
        self.FirstName = FirstName
        self.LastName = LastName
        self.Department = Department
    }
}
