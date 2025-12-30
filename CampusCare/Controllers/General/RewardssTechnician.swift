//
//  RewardssTechnician.swift
//  CampusCare
//
//  Created by rentamac on 12/27/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class RewardssTechnician: UIViewController {

    @IBOutlet weak var nameLabell: UILabel!
    @IBOutlet weak var pointsLabell: UILabel!
    @IBOutlet weak var progressVieww:UIProgressView!
    @IBOutlet weak var bronzeeLabel: UIImageView!
    @IBOutlet weak var silverrLabel: UIImageView!
    @IBOutlet weak var golddLabel: UIImageView!
    @IBOutlet weak var motivationnLabel: UILabel!
    
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
           super.viewDidLoad()
           title = "Rewards"
           fetchRewards()
       }
    // MARK: - Fetch from Firebase
    private func fetchRewards() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("rewards").document(uid).getDocument { snapshot, error in
            guard
                let data = snapshot?.data(),
                let name = data["name"] as? String,
                let completedTasks = data["completedTasks"] as? Int
            else { return }

            let state = RewardsState(
                name: name,
                completedTasks: completedTasks
            )

            self.updateUI(state: state)
        }
    }

    // MARK: - Update UI
    private func updateUI(state: RewardsState) {

        let rewards = Rewards.shared
        let points = state.points
        let badge = rewards.currentBadge(points: points)

        nameLabell.text = state.name
        pointsLabell.text = "Total Points: \(points)"

        let target = rewards.nextBadgeTarget(points: points)
        let previous: Int

        switch badge {
        case .none: previous = 0
        case .bronze: previous = rewards.bronzePoints
        case .silver: previous = rewards.silverPoints
        case .gold: previous = rewards.goldPoints
        }

        let progress = Float(points - previous) / Float(target - previous)
        progressVieww.progress = max(0, min(progress, 1))

        setBadge(bronzeeLabel, unlocked: points >= rewards.bronzePoints, color: .systemOrange)
        setBadge(silverrLabel, unlocked: points >= rewards.silverPoints, color: .systemGray)
        setBadge(golddLabel, unlocked: points >= rewards.goldPoints, color: .systemYellow)

        motivationnLabel.text = rewards.motivationText(badge: badge)
    }

    private func setBadge(_ icon: UIImageView, unlocked: Bool, color: UIColor) {
        icon.image = UIImage(systemName: "medal.fill")
        icon.tintColor = unlocked ? color : .systemGray3
        icon.alpha = unlocked ? 1.0 : 0.35
    }

    // MARK: - Call when task completed
    func taskCompleted() {

        guard let uid = Auth.auth().currentUser?.uid else { return }

        let docRef = db.collection("rewards").document(uid)

        docRef.getDocument { snapshot, _ in
            guard let data = snapshot?.data(),
                  let completed = data["completedTasks"] as? Int,
                  let name = data["name"] as? String
            else { return }

            let oldPoints = completed * 10
            let oldBadge = Rewards.shared.currentBadge(points: oldPoints)

            let newCompleted = completed + 1
            let newPoints = newCompleted * 10
            let newBadge = Rewards.shared.currentBadge(points: newPoints)

            docRef.updateData([
                "completedTasks": newCompleted
            ])

            if newBadge != oldBadge && newBadge != .none {
                self.showBadgePopup(badge: newBadge)
            }

            let state = RewardsState(
                name: name,
                completedTasks: newCompleted
            )
            self.updateUI(state: state)
        }
    }

    // MARK: - Popup
    private func showBadgePopup(badge: Badge) {

        let title = "Congratulations!"
        let message: String

        switch badge {
        case .bronze:
            message = "You earned the BRONZE TECHNICIAN badge!\n\n5 tasks completed successfully."
        case .silver:
            message = "You earned the SILVER TECHNICIAN badge!\n\n30 tasks completed successfully."
        case .gold:
            message = "You earned the GOLD TECHNICIAN badge!\n\n60 tasks completed successfully."
        default:
            return
        }

        showSimpleAlert(title: title, message: message)
    }
}
