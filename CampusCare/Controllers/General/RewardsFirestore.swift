//
//  Rewardss.swift
//  CampusCare
//
//  Created by rentamac on 12/27/25.
//

import Foundation
import FirebaseFirestore

final class FirestoreService {

    private let db = Firestore.firestore()

    // MARK: - Collection Names
    private let UsersCollection = "Users"
    private let RequestsCollection = "Requests"
    private let SettingsCollection = "Settings"
    private let rewardsDocId = "TechniciansRewards" // must match Firebase exactly

    // MARK: - Load reward setting (NO hardcoding)
    func fetchMinCompletedTasks(completion: @escaping (Int) -> Void) {
        db.collection(SettingsCollection)
            .document(rewardsDocId)
            .getDocument { snapshot, _ in
                let minTasks = snapshot?["minCompletedTasks"] as? Int ?? 0
                completion(minTasks)
            }
    }

    // MARK: - Load technicians from users
    func fetchTechnicians(completion: @escaping ([RewardsUser]) -> Void) {
        db.collection(UsersCollection)
            .whereField("Role", isEqualTo: "Technician")
            .getDocuments { snapshot, _ in

                let technicians = snapshot?.documents.compactMap { doc -> RewardsUser? in
                    let name = doc["Username"] as? String ?? "Unknown"
                    let role = doc["Role"] as? String ?? ""
                    return RewardsUser(id: doc.documentID, name: name, role: role)
                } ?? []

                completion(technicians)
            }
    }

    // MARK: - Calculate stats for technician
    func fetchStats(
        for technician: RewardsUser,
        weekStart: Date,
        weekEnd: Date,
        completion: @escaping (TechStats) -> Void
    ) {

        db.collection(RequestsCollection)
            .whereField("assignTechID", isEqualTo: technician.id)
            .getDocuments { snapshot, _ in

                let docs = snapshot?.documents ?? []
                let totalAssigned = docs.count

                let completedThisWeek = docs.filter { doc in
                    guard let timestamp = doc["completedDate"] as? Timestamp else { return false }
                    let date = timestamp.dateValue()
                    return date >= weekStart && date < weekEnd

                }.count

                completion(
                    TechStats(
                        techId: technician.id,
                        techName: technician.name,
                        totalAssigned: totalAssigned,
                        completedThisWeek: completedThisWeek
                    )
                )
            }
    }
}

