//
//  Rewardss.swift
//  CampusCare
//
//  Created by rentamac on 12/27/25.
//

import UIKit
import Foundation


enum Badge {
    case none
    case bronze
    case silver
    case gold
}

// MARK: - Stored State
struct RewardsState: Codable {
    var technicianName: String = "Adam Ahmed"
    var completedTasks: Int = 0

    // Points derived from tasks
    var points: Int {
        completedTasks * 10
    }
}





final class Rewards {

    static let shared = Rewards()
    private init() {}

    private let storageKey = "rewards_state"

    // Badge thresholds (POINTS)
    let bronzePoints = 50
    let silverPoints = 300
    let goldPoints   = 600

    // Load / Save
    var state: RewardsState {
        get {
            if let data = UserDefaults.standard.data(forKey: storageKey),
               let decoded = try? JSONDecoder().decode(RewardsState.self, from: data) {
                return decoded
            }
            return RewardsState()
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: storageKey)
            }
        }
    }

    // Current badge based on POINTS
    func currentBadge() -> Badge {
        let p = state.points
        if p >= goldPoints { return .gold }
        if p >= silverPoints { return .silver }
        if p >= bronzePoints { return .bronze }
        return .none
    }

    // Next badge target (POINTS)
    func nextBadgeTarget() -> Int {
        let p = state.points
        if p < bronzePoints { return bronzePoints }
        if p < silverPoints { return silverPoints }
        if p < goldPoints   { return goldPoints }
        return goldPoints
    }

    // Motivation text
    func motivationText() -> String {
        switch currentBadge() {
        case .none:
            return "Complete 5 tasks to earn your Bronze badge 🥉"
        case .bronze:
            return "Great job! Keep going to reach Silver 🥈"
        case .silver:
            return "Awesome work! You're close to Gold 🥇"
        case .gold:
            return "Outstanding! You reached the highest badge 🎉"
        }
    }
}
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


