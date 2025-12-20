import FirebaseFirestore

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
    
//prefix search
        func searchRequests(prefix: String, completion: @escaping (Result<[RequestModel], Error>) -> Void) {

            // emptey search do all request
            if prefix.isEmpty {
                fetchAllRequests(completion: completion)
                return
            }

            let endText = prefix + "\u{f8ff}"

            requestsCollectionRef
                .whereField("title", isGreaterThanOrEqualTo: prefix)
                .whereField("title", isLessThanOrEqualTo: endText)
                .getDocuments { snapshot, error in
                    
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        completion(.success([]))
                        return
                    }
                    
                    let results = documents.compactMap { RequestModel(from: $0) }
                    completion(.success(results))
                }
        }
    
    func assignRequest(reqID: String, techID: String, assignedDate: Timestamp, completion: @escaping (Result<Void, Error>) -> Void) {
        let requestDocRef = requestsCollectionRef.document(reqID)
        
        //  update fieldss
        let updateData: [String: Any] = [
            "assignTechID": techID,
            "assignedDate": assignedDate,
            "status": "Assigned"
        ]
        
        requestDocRef.updateData(updateData) { error in
            if let error = error {
                print("Failed to assign request: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print(" Request successfully assigned.")
                completion(.success(()))
            }
        }
    }
}
