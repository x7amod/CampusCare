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

   
    @IBOutlet weak var techNameLabel: UILabel!
    @IBOutlet weak var tasksLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
  
        private let service = FirestoreService()

        override func viewDidLoad() {
            super.viewDidLoad()
            progressView.progress = 0
          
            loadTechnicianOfWeek()
        }

        private func loadTechnicianOfWeek() {

            let now = Date()
            let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: now)!.start
            let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart)!

            service.fetchMinCompletedTasks { minTasks in
                self.service.fetchTechnicians { technicians in

                    let group = DispatchGroup()
                    var allStats: [TechStats] = []

                    for tech in technicians {
                        group.enter()
                        self.service.fetchStats(
                            for: tech,
                            weekStart: weekStart,
                            weekEnd: weekEnd
                        ) { stats in
                            allStats.append(stats)
                            group.leave()
                        }
                    }

                    group.notify(queue: .main) {
                        let qualified = allStats.filter {
                            $0.completedThisWeek >= minTasks
                        }

                        guard let winner = qualified.max(by: {
                            $0.completedThisWeek < $1.completedThisWeek
                        }) else {
                            self.showNoWinner()
                            return
                        }

                        self.updateUI(with: winner)
                    }
                }
            }
        }

        private func updateUI(with stats: TechStats) {
            
            techNameLabel.text = stats.techName
            tasksLabel.text = "\(stats.completedThisWeek) / \(stats.totalAssigned) Completed Tasks"
            progressView.setProgress(stats.progress, animated: true)
        }

        private func showNoWinner() {
            techNameLabel.text = "-"
            tasksLabel.text = "No technician qualified this week"
            progressView.setProgress(0, animated: true)
            
        }
    }
