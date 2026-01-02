//
//  UIViewController+NotificationBell.swift
//  CampusCare
//

import UIKit

extension UIViewController {
    
    func addNotificationBell() {
        // Don't show notification bell for Admin users
        if UserStore.shared.currentUserRole == "Admin" {
            return
        }
        
        let bellButton = UIButton(type: .system)

        let normalImage = UIImage(systemName: "bell.fill")?
            .withRenderingMode(.alwaysTemplate)

        let badgeImage = UIImage(systemName: "bell.badge.fill")?
            .withRenderingMode(.alwaysOriginal) // making it multicolored for red badge

        bellButton.setImage(normalImage, for: .normal)

        fetchUnreadNotificationCount { count in DispatchQueue.main.async {
                if count > 0 { bellButton.setImage(badgeImage, for: .normal)}}}

        bellButton.tintColor = .white
        bellButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        bellButton.addTarget(
            self,
            action: #selector(handleNotificationBellTap),
            for: .touchUpInside
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bellButton)
    }

    
    @objc private func handleNotificationBellTap() {
        let storyboard = UIStoryboard(name: "Notifications", bundle: nil)
        guard let notificationsVC = storyboard.instantiateViewController(withIdentifier: "NotificationsViewController") as? NotificationsViewController else {
            return
        }
        navigationController?.pushViewController(notificationsVC, animated: true)
    }
    
    private func fetchUnreadNotificationCount(completion: @escaping (Int) -> Void) {
        guard let userID = UserStore.shared.currentUserID else {
            completion(0)
            return
        }
        
        let notificationsCollection = NotificationsCollection()
        notificationsCollection.fetchUnreadCount(for: userID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let count):
                    completion(count)
                case .failure:
                    completion(0)
                }
            }
        }
    }
    
}
