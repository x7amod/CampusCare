import FirebaseFirestore

final class ReportCollection{
    private let reportsCollectionRef = FirestoreManager.shared.db.collection("Reports")

    func createReport(url: String, releaseDate: Timestamp = Timestamp(date: Date()), completion: ((Error?) -> Void)? = nil) {
            
            // Firestore dictionary
            let reportData: [String: Any] = [
                "pdfURL": url,
                "releaseDate": releaseDate
            ]
            
            // Add document
            reportsCollectionRef.addDocument(data: reportData) { error in
                if let error = error {
                    print("Error creating report: \(error.localizedDescription)")
                } else {
                    print("Report created successfully")
                }
                completion?(error)
            }
        }
    
}
