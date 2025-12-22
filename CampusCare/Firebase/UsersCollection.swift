import FirebaseFirestore
final class     UsersCollection{
    static let shared = UsersCollection()

    private let usersCollectionRef = FirestoreManager.shared.db.collection("Users")

   

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


