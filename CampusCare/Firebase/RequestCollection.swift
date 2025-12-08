
final class RequestCollection {
    private let requestsCollectionRef = FirestoreManager.shared.db.collection("Requests")
    
    func createNewRequest(data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        
        requestsCollectionRef.addDocument(data: data) { error in
            
            // 2. Check the 'error' parameter
            if let error = error {
             
                print("Error creating new request document: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                
                print("✅ New request document successfully created.")
                completion(.success(()))
            }
        }
    }
    
    func fetchAllRequests(completion: @escaping (Result<[RequestModel], Error>) -> Void) {
            requestsCollectionRef.getDocuments { snapshot, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let requests: [RequestModel] = documents.compactMap { doc in
                    RequestModel(from: doc)
                }
                
                completion(.success(requests))
            }
        }
}
