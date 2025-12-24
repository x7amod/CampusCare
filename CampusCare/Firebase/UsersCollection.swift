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
    }
