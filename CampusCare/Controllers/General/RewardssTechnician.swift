//
//  RewardssTechnician.swift
//  CampusCare
//
//  Created by rentamac on 12/27/25.
//

import UIKit

final class RewardssTechnician: UIViewController {

    @IBOutlet weak var nameLabell: UILabel!
    @IBOutlet weak var pointsLabell: UILabel!
    @IBOutlet weak var progressVieww:UIProgressView!
    @IBOutlet weak var bronzeeLabel: UIImageView!
    @IBOutlet weak var silverrLabel: UIImageView!
    @IBOutlet weak var golddLabel: UIImageView!
    @IBOutlet weak var motivationnLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rewards"
               updateUI()
    }
    
    // MARK: - Update Screen
    private func updateUI() {

        let rewards = Rewards.shared
        let state = rewards.state
        let points = state.points

        // User info
        nameLabell.text = state.technicianName
        pointsLabell.text = "Total Points: \(points)"

        // Progress bar (POINT BASED)
        let target = rewards.nextBadgeTarget()
        let previous: Int

        switch rewards.currentBadge() {
        case .none:
            previous = 0
        case .bronze:
            previous = rewards.bronzePoints
        case .silver:
            previous = rewards.silverPoints
        case .gold:
            previous = rewards.goldPoints
        }

        let progress = Float(points - previous) / Float(target - previous)
        progressVieww.progress = max(0, min(progress, 1))

        // Badges
        setBadge(bronzeeLabel, unlocked: points >= rewards.bronzePoints, color: .systemOrange)
        setBadge(silverrLabel, unlocked: points >= rewards.silverPoints, color: .systemGray)
        setBadge(golddLabel, unlocked: points >= rewards.goldPoints, color: .systemGreen)
        // Motivation
        motivationnLabel.text = rewards.motivationText()
    }

    private func setBadge(_ icon: UIImageView, unlocked: Bool, color: UIColor) {
        icon.image = UIImage(systemName: "medal.fill")
        icon.tintColor = unlocked ? color : .systemGray3
        icon.alpha = unlocked ? 1.0 : 0.35
    }

    // MARK: - Demo Button (testing only)
    @IBAction func addTaskForTesting(_ sender: Any) {

        let rewards = Rewards.shared
        var state = rewards.state

        let oldBadge = rewards.currentBadge()

        // Simulate task completion
        state.completedTasks += 1
        rewards.state = state

        let newBadge = rewards.currentBadge()

        // Show popup only if badge changed
        if newBadge != oldBadge && newBadge != .none {
            showBadgeUnlockedAlert(badge: newBadge)
        }

        updateUI()
    }

    // MARK: - Popup using shared alert
    private func showBadgeUnlockedAlert(badge: Badge) {

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

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
