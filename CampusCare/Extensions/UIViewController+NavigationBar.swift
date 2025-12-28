//
//  UIViewController+NavigationBar.swift
//  CampusCare
//
//  Created on 12/26/25.
//

import UIKit

extension UIViewController {
    
    /// Sets up the navigation bar with custom styling
    /// - Parameter showNotificationBell: Whether to show the notification bell button (default: true)
    func setupCampusCareNavigationBar(showNotificationBell: Bool = true) {
        // Apply custom navigation bar appearance
        NavigationBarStyleManager.shared.applyNavigationBarStyle(to: navigationController?.navigationBar)
        
        // Add notification bell if requested and not on NotificationsViewController
        if showNotificationBell && !(self is NotificationsViewController) {
            addNotificationBell()
        }
    }
    
    /// Hides the navigation bar
    func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    /// Shows the navigation bar
    func showNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    /// Sets the navigation bar title with custom styling
    /// - Parameter title: The title to display
    func setNavigationTitle(_ title: String) {
        self.title = title
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
    }
}

