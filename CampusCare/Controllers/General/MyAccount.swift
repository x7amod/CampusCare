//
//  MyAccount.swift
//  CampusCare
//
//  Created by dar on 31/12/2025.
//

import UIKit
import FirebaseAuth

final class MyAccount: UIViewController {

    @IBOutlet weak var MyAccountCard: UIView!
    @IBOutlet weak var ChagePassword: UIView!
    @IBOutlet weak var Logout: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGestures()
        setupCardStyles()
    }

    private func setupCardStyles() {
        MyAccountCard.layer.cornerRadius = 15
        MyAccountCard.layer.shadowColor = UIColor.black.cgColor
        MyAccountCard.layer.shadowOpacity = 0.1
        MyAccountCard.layer.shadowRadius = 10
        MyAccountCard.layer.shadowOffset = CGSize(width: 0, height: 6)
        MyAccountCard.layer.masksToBounds = false

        ChagePassword.layer.cornerRadius = 0
        ChagePassword.layer.masksToBounds = true

        Logout.layer.cornerRadius = 0
        Logout.layer.masksToBounds = true
    }

    private func setupTapGestures() {
        ChagePassword.isUserInteractionEnabled = true
        Logout.isUserInteractionEnabled = true

        let changeTap = UITapGestureRecognizer(target: self, action: #selector(changePasswordTapped))
        ChagePassword.addGestureRecognizer(changeTap)

        let logoutTap = UITapGestureRecognizer(target: self, action: #selector(logoutTapped))
        Logout.addGestureRecognizer(logoutTap)
    }

    @objc private func changePasswordTapped() {
        let storyboard = UIStoryboard(name: "More", bundle: nil)

        guard let controller = storyboard.instantiateViewController(
            withIdentifier: "ResetPassword"
        ) as? ResetPassword else {
            showAlert(title: "Error", message: "ResetPassword screen not found.")
            return
        }

        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })

        present(alert, animated: true)
    }

    private func performLogout() {
        do {
            try Auth.auth().signOut()

            UserDefaults.standard.removeObject(forKey: "isLoggedIn")
            UserDefaults.standard.removeObject(forKey: "userID")
            UserDefaults.standard.removeObject(forKey: "userRole")
            UserDefaults.standard.removeObject(forKey: "username")

            UserStore.shared.currentUserID = nil
            UserStore.shared.currentUserRole = nil
            UserStore.shared.currentUsername = nil
            UserStore.shared.currentTechID = nil

            resetAppToLogin()
        } catch {
            showAlert(title: "Logout Failed", message: error.localizedDescription)
        }
    }

    private func resetAppToLogin() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rootController = storyboard.instantiateViewController(withIdentifier: "login")

            let navigation = UINavigationController(rootViewController: rootController)
            navigation.setNavigationBarHidden(true, animated: false)

            guard let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                return
            }

            window.rootViewController = navigation
            window.makeKeyAndVisible()
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
