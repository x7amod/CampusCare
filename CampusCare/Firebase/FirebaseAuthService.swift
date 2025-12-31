//
//  FirebaseAuthService.swift
//  CampusCare
//
//  Created by dar on 31/12/2025.
//

import Foundation
import FirebaseAuth

final class FirebaseAuthService {
    static let shared = FirebaseAuthService()
    private init() {}

    func changePassword(currentPassword: String,
                        newPassword: String,
                        completion: @escaping (Result<Void, Error>) -> Void) {

        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(
                domain: "FirebaseAuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No logged-in user."]
            )))
            return
        }

        guard let email = user.email else {
            completion(.failure(NSError(
                domain: "FirebaseAuthService",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Current user has no email. Cannot re-authenticate."]
            )))
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)

        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
        }
    }

    func signOut() -> Result<Void, Error> {
        do {
            try Auth.auth().signOut()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}

