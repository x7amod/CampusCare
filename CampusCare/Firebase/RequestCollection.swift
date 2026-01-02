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
    
    // Fetch requests created by a specific user, sorted by most recent first
    func fetchRequestsForUser(userID: String, completion: @escaping (Result<[RequestModel], Error>) -> Void) {
        requestsCollectionRef
            .whereField("creatorID", isEqualTo: userID)
            .order(by: "releaseDate", descending: true)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("[RequestCollection] fetchRequestsForUser error: \(error.localizedDescription)")
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
                
                print("[RequestCollection] Fetched \(requests.count) requests for user: \(userID)")
                completion(.success(requests))
            }
    }
    
    /// Fetch the most recently updated requests for a specific user
    /// - Parameters:
    ///   - userID: The ID of the user whose requests to fetch
    ///   - limit: Maximum number of requests to return (default: 2)
    ///   - completion: Result containing array of RequestModel or Error
    func fetchRecentRequests(userID: String, limit: Int = 2, completion: @escaping (Result<[RequestModel], Error>) -> Void) {
        requestsCollectionRef
            .whereField("creatorID", isEqualTo: userID)
            .order(by: "lastUpdateDate", descending: true)
            .limit(to: limit)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("[RequestCollection] fetchRecentRequests error: \(error.localizedDescription)")
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
                
                print("[RequestCollection] Fetched \(requests.count) recent requests for user: \(userID)")
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
                
                if let error = error {
                    
                    print("Error creating new request document: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    
                    print(" New request document successfully created.")
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
            
                requestDocRef.updateData(updateData) { [weak self] error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    print(" Request successfully assigned.")
                    
                    // Fetch request details to send notifications
                    requestDocRef.getDocument { snapshot, error in
                        guard let data = snapshot?.data(),
                              let requestTitle = data["title"] as? String,
                              let creatorID = data["creatorID"] as? String else {
                            print("[RequestCollection] Could not fetch request details for notifications")
                            completion(.success(()))
                            return
                        }
                        
                        // Send notifications to creator and technician
                        self?.notifyOnRequestAssignment(
                            requestID: reqID,
                            requestTitle: requestTitle,
                            creatorID: creatorID,
                            techID: techID
                        )
                        
                        completion(.success(()))
                    }
                }
            }
        }
        
    //added by reem to fetch tech tasks
    func fetchRequestsForTech(techID: String, completion: @escaping (Result<[RequestModel], Error>) -> Void) {
        requestsCollectionRef
            .whereField("assignTechID", isEqualTo: techID)
        .whereField("status", in: ["Assigned", "In Progress", "New" ]) // Optional: filter by status potato, removed new
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
    
    // MARK: - Status Updates
    
    /// Update request status (In-Progress or Complete)
    /// - Parameters:
    ///   - requestID: The ID of the request to update
    ///   - newStatus: The new status ("In-Progress" or "Complete")
    ///   - completion: Result with success or Error
    func updateRequestStatus(requestID: String, newStatus: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let requestDocRef = requestsCollectionRef.document(requestID)
        
        // Determine which timestamp field to update
        var updateData: [String: Any] = [
            "status": newStatus,
            "lastUpdateDate": Timestamp(date: Date())
        ]
        
        if newStatus == "In-Progress" {
            updateData["inProgressDate"] = Timestamp(date: Date())
        } else if newStatus == "Complete" {
            updateData["completedDate"] = Timestamp(date: Date())
        }
        
        requestDocRef.updateData(updateData) { [weak self] error in
            if let error = error {
                print("[RequestCollection] Failed to update request status: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("[RequestCollection] ✅ Request status updated to \(newStatus)")
                
                // Fetch request details to send notification to creator
                requestDocRef.getDocument { snapshot, error in
                    guard let data = snapshot?.data(),
                          let requestTitle = data["title"] as? String,
                          let creatorID = data["creatorID"] as? String,
                          let techID = data["assignTechID"] as? String else {
                        print("[RequestCollection] Could not fetch request details for notification")
                        completion(.success(()))
                        return
                    }
                    
                    // Send notification to request creator
                    self?.notifyOnStatusUpdate(
                        requestID: requestID,
                        requestTitle: requestTitle,
                        creatorID: creatorID,
                        techID: techID,
                        newStatus: newStatus
                    )
                    
                    completion(.success(()))
                }
            }
        }
    }
    
    // MARK: - Notification Helper Methods
    
    /// Notify manager when a new request is created
    private func notifyManagerOfNewRequest(requestTitle: String) {
        let usersCollection = UsersCollection.shared
        let notificationsCollection = NotificationsCollection()
        
        usersCollection.fetchManagerUserID { managerID in
            guard let managerID = managerID else {
                print("[RequestCollection] Could not find manager to notify")
                return
            }
            
            notificationsCollection.createNotification(
                userID: managerID,
                title: "New Request Awaits Assignment",
                body: "\(requestTitle) has been submitted and needs a technician.",
                type: "New",
                requestID: "" // Request ID not available here since addDocument hasn't returned yet
            ) { result in
                if case .failure(let error) = result {
                    print("[RequestCollection] Failed to notify manager: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Notify creator and technician when request is assigned
    private func notifyOnRequestAssignment(requestID: String, requestTitle: String, creatorID: String, techID: String) {
        let usersCollection = UsersCollection.shared
        let notificationsCollection = NotificationsCollection()
        
        // Fetch technician's full name
        usersCollection.fetchUserFullName(userID: techID) { techName in
            let technicianName = techName ?? "a technician"
            
            // Notify request creator
            notificationsCollection.createNotification(
                userID: creatorID,
                title: "Your Request \(requestTitle) is now Assigned",
                body: "Your Request has been Assigned to \(technicianName).",
                type: "Assigned",
                requestID: requestID
            ) { result in
                if case .failure(let error) = result {
                    print("[RequestCollection] Failed to notify creator: \(error.localizedDescription)")
                }
            }
            
            // Notify assigned technician
            notificationsCollection.createNotification(
                userID: techID,
                title: requestTitle,
                body: "has been Assigned to you!",
                type: "Assigned",
                requestID: requestID
            ) { result in
                if case .failure(let error) = result {
                    print("[RequestCollection] Failed to notify technician: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Notify creator when request status is updated to In-Progress or Complete
    private func notifyOnStatusUpdate(requestID: String, requestTitle: String, creatorID: String, techID: String, newStatus: String) {
        let usersCollection = UsersCollection.shared
        let notificationsCollection = NotificationsCollection()
        
        // Fetch technician's full name
        usersCollection.fetchUserFullName(userID: techID) { techName in
            let technicianName = techName ?? "The technician"
            
            let title: String
            let body: String
            
            if newStatus == "In-Progress" {
                title = "\(requestTitle) is now In-Progress"
                body = "\(technicianName) has started working on your request."
            } else if newStatus == "Complete" {
                title = "\(requestTitle) is now Complete"
                body = "\(technicianName) has marked your request as Complete."
            } else {
                // Unknown status, don't send notification
                return
            }
            
            // Notify request creator
            notificationsCollection.createNotification(
                userID: creatorID,
                title: title,
                body: body,
                type: newStatus,
                requestID: requestID
            ) { result in
                if case .failure(let error) = result {
                    print("[RequestCollection] Failed to notify creator of status update: \(error.localizedDescription)")
                }
            }
        }
    }
    

}
