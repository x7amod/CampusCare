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
}
