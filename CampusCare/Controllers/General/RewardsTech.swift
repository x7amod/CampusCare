////import UIKit
//
//final class RewardsTechnician: UIViewController {
//
//    // MARK: - Outlets 
//    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var pointsLabel: UILabel!
//    @IBOutlet weak var progressView: UIProgressView!
//
//    @IBOutlet weak var bronzeIcon: UIImageView!
//    @IBOutlet weak var silverIcon: UIImageView!
//    @IBOutlet weak var goldIcon: UIImageView!
//
//    @IBOutlet weak var motivationLabel: UILabel!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "Rewards"
//        updateUI()
//    }
//
//    // MARK: - Update Screen
//    private func updateUI() {
//
//        let rewards = Rewards.shared
//        let state = rewards.state
//        let points = state.points
//
//        // User info
//        nameLabel.text = state.technicianName
//        pointsLabel.text = "Total Points: \(points)"
//
//        // Progress bar (POINT BASED)
//        let target = rewards.nextBadgeTarget()
//        let previous: Int
//
//        switch rewards.currentBadge() {
//        case .none:
//            previous = 0
//        case .bronze:
//            previous = rewards.bronzePoints
//        case .silver:
//            previous = rewards.silverPoints
//        case .gold:
//            previous = rewards.goldPoints
//        }
//
//        let progress = Float(points - previous) / Float(target - previous)
//        progressView.progress = max(0, min(progress, 1))
//
//        // Badges
//        setBadge(bronzeIcon, unlocked: points >= rewards.bronzePoints, color: .systemOrange)
//        setBadge(silverIcon, unlocked: points >= rewards.silverPoints, color: .systemGray)
//        setBadge(goldIcon,   unlocked: points >= rewards.goldPoints,   color: .systemYellow)
//
//        // Motivation
//        motivationLabel.text = rewards.motivationText()
//    }
//
//    private func setBadge(_ icon: UIImageView, unlocked: Bool, color: UIColor) {
//        icon.image = UIImage(systemName: "medal.fill")
//        icon.tintColor = unlocked ? color : .systemGray3
//        icon.alpha = unlocked ? 1.0 : 0.35
//    }
//
//    // MARK: - Demo Button (testing only)
//    @IBAction func addTaskForTesting(_ sender: Any) {
//
//        let rewards = Rewards.shared
//        var state = rewards.state
//
//        let oldBadge = rewards.currentBadge()
//
//        // Simulate task completion
//        state.completedTasks += 1
//        rewards.state = state
//
//        let newBadge = rewards.currentBadge()
//
//        // Show popup only if badge changed
//        if newBadge != oldBadge && newBadge != .none {
//            showBadgeUnlockedAlert(badge: newBadge)
//        }
//
//        updateUI()
//    }
//
//    // MARK: - Popup using shared alert
//    private func showBadgeUnlockedAlert(badge: Badge) {
//
//        let title = "Congratulations!"
//        let message: String
//
//        switch badge {
//        case .bronze:
//            message = "You earned the BRONZE TECHNICIAN badge!\n\n5 tasks completed successfully."
//        case .silver:
//            message = "You earned the SILVER TECHNICIAN badge!\n\n30 tasks completed successfully."
//        case .gold:
//            message = "You earned the GOLD TECHNICIAN badge!\n\n60 tasks completed successfully."
//        default:
//            return
//        }
//
//        showSimpleAlert(title: title, message: message)
//    }
//}
////
