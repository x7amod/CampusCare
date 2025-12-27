//
//  AppNavigationController.swift
//  CampusCare
//

import UIKit

class AppNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let isNotificationsVC = viewController is NotificationsViewController
        
        if !isNotificationsVC {
            viewController.addNotificationBell()
        }
    }
}
