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
        applyCardStyle(to: MyAccountCard)

        ChagePassword.layer.cornerRadius = 0
        ChagePassword.layer.masksToBounds = true

        Logout.layer.cornerRadius = 0
        Logout.layer.masksToBounds = true
    }

    private func applyCardStyle(to view: UIView) {
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.masksToBounds = false
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

        guard let vc = storyboard.instantiateViewController(withIdentifier: "ResetPassword") as? ResetPassword else {
            showAlert(title: "Error", message: "ResetPassword screen not found.")
            return
        }

        navigationController?.pushViewController(vc, animated: true)
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
            resetAppToLogin()
        } catch {
            showAlert(title: "Logout Failed", message: error.localizedDescription)
        }
    }

    private func resetAppToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "login")

        let nav = UINavigationController(rootViewController: loginVC)
        nav.setNavigationBarHidden(true, animated: false)

        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }

        window.rootViewController = nav
        window.makeKeyAndVisible()
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
