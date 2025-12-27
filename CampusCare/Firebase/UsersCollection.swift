import FirebaseFirestore
final class     UsersCollection{
    static let shared = UsersCollection()

    private let usersCollectionRef = FirestoreManager.shared.db.collection("Users")

    func fetchTechnicians(completion: @escaping ([UserModel]) -> Void) {
            usersCollectionRef
                .whereField("Role", isEqualTo: "Technician")
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching users:", error)
                        completion([])
                        return
                    }

                    let users = snapshot?.documents.compactMap {
                        UserModel(from: $0)
                    } ?? []

                    completion(users)
                }
        }

   

    // Get full user info (first, last, role, department, userId, email)
        func getUserInfo(uid: String, completion: @escaping (_ data: [String: Any]?) -> Void) {
            usersCollectionRef.document(uid).getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching user info: \(error)")
                    completion(nil)
                    return
                }

                guard let data = snapshot?.data() else {
                    print("No user document for uid \(uid)")
                    completion(nil)
                    return
                }

                completion(data)
            }
        }
    
    // MARK: - Notification Helper Methods
    
    /// Fetch user's full name (FirstName + LastName)
    /// - Parameters:
    ///   - userID: The ID of the user
    ///   - completion: Returns full name or nil if not found
    func fetchUserFullName(userID: String, completion: @escaping (String?) -> Void) {
        usersCollectionRef.document(userID).getDocument { snapshot, error in
            if let error = error {
                print("[UsersCollection] Error fetching user full name: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = snapshot?.data(),
                  let firstName = data["First Name"] as? String,
                  let lastName = data["Last Name"] as? String else {
                print("[UsersCollection] Could not find name fields for user \(userID)")
                completion(nil)
                return
            }
            
            let fullName = "\(firstName) \(lastName)"
            completion(fullName)
        }
    }
    
    /// Fetch the first Manager user's ID
    /// - Parameter completion: Returns manager user ID or nil if not found
    func fetchManagerUserID(completion: @escaping (String?) -> Void) {
        usersCollectionRef
            .whereField("Role", isEqualTo: "Manager")
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("[UsersCollection] Error fetching manager: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("[UsersCollection] No manager found in database")
                    completion(nil)
                    return
                }
                
                completion(document.documentID)
            }
    }
    
    /// Fetch user's first name only (for greeting)
    /// - Parameters:
    ///   - userID: The ID of the user
    ///   - completion: Returns first name or nil if not found
    func fetchUserFirstName(userID: String, completion: @escaping (String?) -> Void) {
        usersCollectionRef.document(userID).getDocument { snapshot, error in
            if let error = error {
                print("[UsersCollection] Error fetching user first name: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = snapshot?.data(),
                  let firstName = data["First Name"] as? String else {
                print("[UsersCollection] Could not find First Name field for user \(userID)")
                completion(nil)
                return
            }
            
            completion(firstName)
        }
    }
}
