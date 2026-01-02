//
//  ModelsRewards.swift
//  CampusCare
//
//  Created by rentamac on 1/2/26.
//

import Foundation


struct RewardsUser {
    let id: String
    let name: String
    let role: String
}

struct TechStats {
    let techId: String
    let techName: String
    let totalAssigned: Int
    let completedThisWeek: Int

    var progress: Float {
        guard totalAssigned > 0 else { return 0 }
        return Float(completedThisWeek) / Float(totalAssigned)
    }
}

