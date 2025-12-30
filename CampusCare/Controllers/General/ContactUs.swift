//
//  ContactUs.swift
//  CampusCare
//
//  Created by Malak on 12/27/25.
//

import UIKit

class ContactUs: UIViewController {
    
    @IBAction func emailTapped(_ sender: UIButton) {
        
        let email = "campuscare4@gmail.com"

           let actionSheet = UIAlertController(
               title: "Email Support",
               message: "Reach CampusCare through the below email address!",
               preferredStyle: .actionSheet
           )

           let emailAction = UIAlertAction(title: email, style: .default) { _ in
               if let url = URL(string: "mailto:\(email)") {
                   UIApplication.shared.open(url)
               } else {
                   self.showEmailInfo(email)
               }
           }

           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

           actionSheet.addAction(emailAction)
           actionSheet.addAction(cancelAction)

           // iPad safety
           if let popover = actionSheet.popoverPresentationController {
               popover.sourceView = sender
               popover.sourceRect = sender.bounds
           }

           present(actionSheet, animated: true)
    }
    
    private func showEmailInfo(_ email: String) {
        let alert = UIAlertController(
            title: "Contact Email",
            message: email,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    
    
    @IBAction func callTapped(_ sender: UIButton) {
        
        let phoneNumber = "+973 39554431"

            let actionSheet = UIAlertController(
                title: "Contact Support",
                message: "Contact us through the below phone number!",
                preferredStyle: .actionSheet
            )

            
            let callAction = UIAlertAction(title: phoneNumber, style: .default) { _ in
                if let url = URL(string: "tel://\(phoneNumber)") {
                    UIApplication.shared.open(url)
                }
            }

            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

            actionSheet.addAction(callAction)
            actionSheet.addAction(cancelAction)

            // Required for iPad (safe practice) to make it responsive
            if let popover = actionSheet.popoverPresentationController {
                popover.sourceView = sender
                popover.sourceRect = sender.bounds
            }

            present(actionSheet, animated: true)
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
