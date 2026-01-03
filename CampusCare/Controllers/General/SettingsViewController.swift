//
//  SettingsViewController.swift
//  CampusCare
//
//  Created by m1 on 01/01/2026.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var profileCardView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userRoleLabel: UILabel!
    @IBOutlet weak var optionsCardView: UIView!
    @IBOutlet weak var termsRow: UIView!
    @IBOutlet weak var aboutRow: UIView!
    @IBOutlet weak var contactUsRow: UIView!
    @IBOutlet weak var rewardsRow: UIView!
    @IBOutlet weak var myAccountRow: UIView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationRow: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCardStyles()
        setupRowTapGestures()
        setupNotificationSwitch()
        loadUserData()
    }
    
    // MARK: - Setup Methods
    private func setupCardStyles() {
        // Profile Card Style
        profileCardView.layer.cornerRadius = 5
        profileCardView.layer.shadowColor = UIColor.black.cgColor
        profileCardView.layer.shadowOpacity = 0.15
        profileCardView.layer.shadowRadius = 6
        profileCardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        profileCardView.layer.masksToBounds = false
        
        // Options Card Style
        optionsCardView.layer.cornerRadius = 15
        optionsCardView.layer.shadowColor = UIColor.black.cgColor
        optionsCardView.layer.shadowOpacity = 0.1
        optionsCardView.layer.shadowRadius = 10
        optionsCardView.layer.shadowOffset = CGSize(width: 0, height: 6)
        optionsCardView.layer.masksToBounds = false
        
    }
    // make rows tappable
    private func setupRowTapGestures() {
        let myAccountTap = UITapGestureRecognizer(target: self, action: #selector(myAccountTapped))
        myAccountRow.addGestureRecognizer(myAccountTap)
        myAccountRow.isUserInteractionEnabled = true
        
        let contactTap = UITapGestureRecognizer(target: self, action: #selector(contactTapped))
        contactUsRow.addGestureRecognizer(contactTap)
        contactUsRow.isUserInteractionEnabled = true
        
        let aboutTap = UITapGestureRecognizer(target: self, action: #selector(aboutTapped))
        aboutRow.addGestureRecognizer(aboutTap)
        aboutRow.isUserInteractionEnabled = true
        
        let termsTap = UITapGestureRecognizer(target: self, action: #selector(termsTapped))
        termsRow.addGestureRecognizer(termsTap)
        termsRow.isUserInteractionEnabled = true
        
        let rewardsTap = UITapGestureRecognizer(target: self, action: #selector(rewardsTapped))
        rewardsRow.addGestureRecognizer(rewardsTap)
        rewardsRow.isUserInteractionEnabled = true
    }
    
    private func setupNotificationSwitch() {
        // Set initial state from UserStore
        notificationSwitch.isOn = UserStore.shared.notificationsEnabled
    }
    
    private func loadUserData() {
        // Load data if available, otherwise leave labels as default from storyboard
        
        // Load username from UserStore (if available)
        if let userID = UserStore.shared.currentUserID {
            UsersCollection.shared.fetchUserFullName(userID: userID) { [weak self] fullName in
                DispatchQueue.main.async {
                    if let fullName = fullName, !fullName.isEmpty {
                        self?.userNameLabel.text = fullName
                    }
                    // Otherwise, keep the default label from storyboard
                }
            }
        }
        
        // Load email from Firebase Auth
        if let currentUser = Auth.auth().currentUser,
           let email = currentUser.email, !email.isEmpty {
            userEmailLabel.text = email
        }
        
        // Load role from UserStore
        if let userRole = UserStore.shared.currentUserRole, !userRole.isEmpty {
            userRoleLabel.text = userRole.capitalized
            if (UserStore.shared.currentUserRole == "Admin"){
                notificationRow.isHidden = true
            }
        }
    }
    
    // MARK: - Row Tap Actions
    @objc private func myAccountTapped() {
        navigateToPage(withIdentifier: "MyAccount")
    }
    
    @objc private func contactTapped() {
        navigateToPage(withIdentifier: "ContactUs")
    }
    
    @objc private func aboutTapped() {
        navigateToPage(withIdentifier: "About")
    }
    
    @objc private func rewardsTapped() {
        navigateToPage(withIdentifier: "Rewards")
    }
    
    @objc private func termsTapped() {
        navigateToPage(withIdentifier: "Terms")
    }
    
    private func navigateToPage(withIdentifier identifier: String) {
        guard let storyboard = self.storyboard else {
            print("Error: Storyboard not found")
            showNavigationError(message: "Unable to navigate. Please try again.")
            return
        }
        
        // Check if navigation controller exists
        guard let navigationController = navigationController else {
            print("Error: Navigation controller not found")
            showNavigationError(message: "Navigation unavailable. Please restart the app.")
            return
        }
        
        // Attempt to instantiate the view controller
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showNavigationError(message: String) {
        let alert = UIAlertController(
            title: "Navigation Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - IBActions
    @IBAction func notificationSwitchChanged(_ sender: UISwitch) {
        UserStore.shared.notificationsEnabled = sender.isOn
    }
}
