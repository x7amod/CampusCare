import FirebaseFirestore

final class AnnouncementsCollection {
    // Note: Collection name has spelling error in Firebase ("Announcments" not "Announcements")
    private let announcementsCollectionRef = FirestoreManager.shared.db.collection("Announcments")
    
    /// Fetches all active announcements sorted by priority (ascending: 1, 2, 3...)
    func fetchActiveAnnouncements(completion: @escaping (Result<[AnnouncementModel], Error>) -> Void) {
        announcementsCollectionRef
            .whereField("isActive", isEqualTo: true)
            .order(by: "priority", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("[AnnouncementsCollection] Error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("[AnnouncementsCollection] No announcements found")
                    completion(.success([]))
                    return
                }
                
                let announcements = documents.compactMap { AnnouncementModel(from: $0) }
                print("[AnnouncementsCollection] Fetched \(announcements.count) active announcements")
                completion(.success(announcements))
            }
    }
}
