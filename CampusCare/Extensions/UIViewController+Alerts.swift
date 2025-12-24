//
//  UIViewController+Alerts.swift
//  CampusCare
//
//  Created by m1 on 23/12/2025.
//
import UIKit

extension UIViewController {
    
    // Simple Alert with just an "OK" button
    func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    // Confirmation Alert with "Yes" and "No"
    // The 'completion' closure runs only if the user taps "Yes"
    // Usage Example:
//    showConfirmationAlert(title: "Delete Item?", message: "This cannot be undone.") {
//        <<Put the code you want to run when 'Yes' is clicked here>>
//    }
    func showConfirmationAlert(title: String, message: String, onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            onConfirm()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        self.present(alert, animated: true)
    }
}
