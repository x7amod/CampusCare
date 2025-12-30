//
//  Rewardss.swift
//  CampusCare
//
//  Created by rentamac on 12/27/25.
//

import Foundation

enum Badge {
    case none
    case bronze
    case silver
    case gold
}

struct RewardsState {
    let name: String
    let completedTasks: Int

    var points: Int {
        completedTasks * 10
    }
}

final class Rewards {

    static let shared = Rewards()
    private init() {}

    // Badge thresholds (POINT BASED)
    let bronzePoints = 50
    let silverPoints = 300
    let goldPoints   = 600

    func currentBadge(points: Int) -> Badge {
        if points >= goldPoints { return .gold }
        if points >= silverPoints { return .silver }
        if points >= bronzePoints { return .bronze }
        return .none
    }

    func nextBadgeTarget(points: Int) -> Int {
        if points < bronzePoints { return bronzePoints }
        if points < silverPoints { return silverPoints }
        if points < goldPoints   { return goldPoints }
        return goldPoints
    }

    func motivationText(badge: Badge) -> String {
        switch badge {
        case .none:
            return "Complete tasks to earn your Bronze badge 🥉"
        case .bronze:
            return "Great job! Keep going to reach Silver 🥈"
        case .silver:
            return "Awesome work! You're close to Gold 🥇"
        case .gold:
            return "Outstanding! You reached the highest badge 🎉"
        }
    }
}
