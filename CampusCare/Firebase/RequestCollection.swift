import FirebaseFirestore

final class RequestCollection {
    private let requestsCollectionRef = FirestoreManager.shared.db.collection("Requests")
    private let db = Firestore.firestore()
    
    
    func fetchTechnicians(
            completion: @escaping (Result<[String: String], Error>) -> Void
        ) {
            db.collection("Users")
                .whereField("Role", isEqualTo: "Technician")
                .getDocuments { snapshot, error in

                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        completion(.success([:]))
                        return
                    }

                    var techMap: [String: String] = [:]

                    documents.forEach { doc in
                        if let user = UserModel(from: doc) {
                            techMap[user.id] =
                                "\(user.FirstName) \(user.LastName)"
                        }
                    }

                    completion(.success(techMap))
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

    
    func getRequestsForDate(assignTechID: String,
                            selectedDate: Date,
                            completion: @escaping ([RequestModel]) -> Void) {

        let calendar = Calendar.current

        // LOCAL start & end of day
        let startOfDay = calendar.startOfDay(for: selectedDate)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            completion([])
            return
        }

        print("\nQUERY DEBUG =====================")
        print("Tech ID:", assignTechID)
        print("Selected:", selectedDate.toStringLocal())
        print("Start:", startOfDay.toStringLocal())
        print("End:", endOfDay.toStringLocal())
        print("================================\n")

        let startTimestamp = Timestamp(date: startOfDay)
        let endTimestamp = Timestamp(date: endOfDay)

        db.collection("Requests")
            .whereField("assignTechID", isEqualTo: assignTechID)
            .whereField("assignedDate", isGreaterThanOrEqualTo: startTimestamp)
            .whereField("assignedDate", isLessThan: endTimestamp)
            .getDocuments { snapshot, error in

                if let error = error {
                    print("❌ Firestore error:", error.localizedDescription)
                    completion([])
                    return
                }

                let requests = snapshot?.documents.compactMap {
                    RequestModel(from: $0)
                } ?? []

                print("✅ Found \(requests.count) tasks")
                completion(requests)
            }
    }


        
        
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
        
        func assignRequest(reqID: String, techID: String, assignedDate: Timestamp, deadline: Timestamp, completion: @escaping (Result<Void, Error>) -> Void) {
            let requestDocRef = requestsCollectionRef.document(reqID)
            
            //  update fieldss
            let updateData: [String: Any] = [
                "assignTechID": techID,
                "assignedDate": assignedDate,
                "deadline": deadline,
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
        
        //added by reem to fetch tech tasks
        func fetchRequestsForTech(techID: String, completion: @escaping (Result<[RequestModel], Error>) -> Void) {
            requestsCollectionRef
                .whereField("assignTechID", isEqualTo: techID)
            // .whereField("status", in: ["Assigned", "In Progress" , "New", ]) // Optional: filter by status
                .getDocuments { snapshot, error in
                    
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
        
        ////

}
