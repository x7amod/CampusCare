final class     UsersCollection{
    private let usersCollectionRef = FirestoreManager.shared.db.collection("Users")

    func fetchTechnicians(completion: @escaping ([UserModel]) -> Void) {
            usersCollectionRef
                .whereField("role", isEqualTo: "Tech")
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


}
