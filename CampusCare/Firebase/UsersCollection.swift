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

   

    // Get full user info (firstname, lastname, role, department, username)
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
    }

    



