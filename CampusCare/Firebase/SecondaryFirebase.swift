//
//  SecondaryFirebase.swift
//  CampusCare
//
//  Created by dar on 29/12/2025.
//

import FirebaseCore
import FirebaseAuth

enum SecondaryFirebase {
    static let appName = "SecondaryApp"

    static var auth: Auth {
        
        if let app = FirebaseApp.app(name: appName) {
            return Auth.auth(app: app)
        }

       
        guard let defaultApp = FirebaseApp.app() else {
            fatalError("FirebaseApp not configured. Call FirebaseApp.configure() in AppDelegate/SceneDelegate.")
        }

        FirebaseApp.configure(name: appName, options: defaultApp.options)

        guard let secondaryApp = FirebaseApp.app(name: appName) else {
            fatalError("Failed to create secondary FirebaseApp.")
        }

        return Auth.auth(app: secondaryApp)
    }
}
