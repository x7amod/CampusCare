import FirebaseFirestore

final class RequestCollection {
    private let requestsCollectionRef = FirestoreManager.shared.db.collection("Requests")
    private let db = Firestore.firestore()
    
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
    // RequestCollection.swift - Keep this function ONLY here
    /*func getRequestsForDate(assignTechID: String,
                            selectedDate: Date,
                            completion: @escaping ([RequestModel]) -> Void) {
        
        // Get local start and end of day
        let calendar = Calendar.current
        let startOfDayLocal = calendar.startOfDay(for: selectedDate)
        guard let endOfDayLocal = calendar.date(byAdding: .day, value: 1, to: startOfDayLocal) else {
            print(" Could not calculate end of day")
            completion([])
            return
        }
        
        print("\nQUERY DEBUG =========================================")
        print("Technician ID: \(assignTechID)")
        print("Selected Date (local): \(selectedDate.toStringLocal())")
        print("Start of Day (local): \(startOfDayLocal.toStringLocal())")
        print("End of Day (local): \(endOfDayLocal.toStringLocal())")
        
        // Convert to UTC for Firestore
        let utcTimeZone = TimeZone(identifier: "UTC")!
        var utcCalendar = Calendar.current
        utcCalendar.timeZone = utcTimeZone
        
        // Get UTC start of day (midnight UTC)
        let utcStartComponents = utcCalendar.dateComponents(in: utcTimeZone, from: startOfDayLocal)
        guard let utcStart = utcCalendar.date(from: DateComponents(
            year: utcStartComponents.year,
            month: utcStartComponents.month,
            day: utcStartComponents.day,
            hour: 0,
            minute: 0,
            second: 0
        )) else {
            print(" Could not create UTC start date")
            completion([])
            return
        }
        
        // Get UTC end of day (next day midnight UTC)
        guard let utcEnd = utcCalendar.date(byAdding: .day, value: 1, to: utcStart) else {
            print("Could not create UTC end date")
            completion([])
            return
        }
        
        print("UTC Start: \(utcStart.toStringLocal())")
        print("UTC End: \(utcEnd.toStringLocal())")
        
        // Convert to Timestamps
        let startTimestamp = Timestamp(date: utcStart)
        let endTimestamp = Timestamp(date: utcEnd)
        
        print("Start Timestamp: \(startTimestamp.seconds) seconds")
        print("End Timestamp: \(endTimestamp.seconds) seconds")
        print("====================================================\n")
        
        // Perform the query
        db.collection("Requests")
            .whereField("assignTechID", isEqualTo: assignTechID)
            .whereField("assignedDate", isGreaterThanOrEqualTo: startTimestamp)
            .whereField("assignedDate", isLessThan: endTimestamp)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("❌ Firestore query error: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("📭 No documents found for date \(selectedDate.toStringLocal(format: "yyyy-MM-dd"))")
                    completion([])
                    return
                }
                
                print("✅ Found \(documents.count) documents")
                
                // Debug each found document
                for document in documents {
                    let data = document.data()
                    if let assignedDate = data["assignedDate"] as? Timestamp {
                        let localDate = assignedDate.dateValue()
                        let utcDate = assignedDate.dateValue() // Same date, but interpret as UTC
                        
                        print("📄 Document: \(data["title"] as? String ?? "No title")")
                        print("   Document ID: \(document.documentID)")
                        print("   Assigned Date (UTC): \(assignedDate.dateValue().utcString())")
                        print("   Assigned Date (Local): \(localDate.toStringLocal())")
                        print("   Tech ID: \(data["assignTechID"] as? String ?? "None")")
                        
                        // Check if it falls within our UTC range
                        let isInRange = utcDate >= utcStart && utcDate < utcEnd
                        print("   Within UTC range? \(isInRange)")
                    } else {
                        print("📄 Document: \(data["title"] as? String ?? "No title") - NO ASSIGNED DATE")
                    }
                }
                
                // Convert to RequestModel objects
                let requests = documents.compactMap { document -> RequestModel? in
                    guard let request = RequestModel(from: document) else {
                        print("⚠️ Failed to create RequestModel for document: \(document.documentID)")
                        return nil
                    }
                    
                    // Debug the created model
                    if let assignedDate = request.assignedDate {
                        print("✅ Created RequestModel: \(request.title) for tech: \(request.assignTechID)")
                        print("   Assigned Date: \(assignedDate.dateValue().toStringLocal())")
                    }
                    
                    return request
                }
                
                completion(requests)
            }
    }*/
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
