import FirebaseFirestore
import FirebaseAuth

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

    //to get  the current login user id
    func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }

    func isCurrentUserManager(completion: @escaping (Bool) -> Void) {
            guard let uid = getCurrentUserId() else {
                completion(false)
                return
            }

            getUserInfo(uid: uid) { data in
                guard let data = data, let role = data["Role"] as? String else {
                    completion(false)
                    return
                }
                completion(role == "Manager")
            }
        }

    func isCurrentUserAdmin(completion: @escaping (Bool) -> Void) {
            guard let uid = getCurrentUserId() else {
                completion(false)
                return
            }

            getUserInfo(uid: uid) { data in
                guard let data = data, let role = data["Role"] as? String else {
                    completion(false)
                    return
                }
                completion(role == "Admin")
            }
        }

    func isCurrentUserTech(completion: @escaping (Bool) -> Void) {
            guard let uid = getCurrentUserId() else {
                completion(false)
                return
            }

            getUserInfo(uid: uid) { data in
                guard let data = data, let role = data["Role"] as? String else {
                    completion(false)
                    return
                }
                completion(role == "Technician")
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
         
     //get all user
    func fetchAllUsers(completion: @escaping (Result<[UserModel], Error>) -> Void) {
            usersCollectionRef.getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let users: [UserModel] = documents.compactMap { doc in
                    UserModel(from: doc)
                }
                
                completion(.success(users))
            }
        }
    
    
    
    //fetch users by role
    func fetchUsersByRole(_ role: String, completion: @escaping ([UserModel]) -> Void) {
           usersCollectionRef
               .whereField("Role", isEqualTo: role)
               .getDocuments { snapshot, error in
                   if let error = error {
                       print("Error fetching users by role:", error)
                       completion([])
                       return
            }

                   let users = snapshot?.documents.compactMap { UserModel(from: $0) } ?? []
                   completion(users)
            }
       }
    
    //updating user info
    func updateUser(uid: String, fields: [String: Any], completion: @escaping (Bool) -> Void) {
           usersCollectionRef.document(uid).updateData(fields) { error in
               if let error = error {
                   print("Error updating user:", error)
                   completion(false)
                   return
               }
               completion(true)
           }
       }
    
    //deleting user
    func deleteUserDocument(uid: String, completion: @escaping (Bool) -> Void) {
            usersCollectionRef.document(uid).delete { error in
                if let error = error {
                    print("Error deleting user doc:", error)
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    
    
    
    //Fetch user's name (FirstName + LastName)
   
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
    
    // Fetch the first Manager user's ID
    
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
