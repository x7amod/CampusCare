//
//  LoginViewController.swift
//  CampusCare
//
//  Created by BP-36-201-14 on 29/11/2025.


import UIKit
import FirebaseAuth
import FirebaseFirestore

class Login: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPasswordToggle()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        autoLoginIfPossible()
    }

    private func autoLoginIfPossible() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        guard isLoggedIn else { return }
        guard Auth.auth().currentUser != nil else { return }

        let savedUserID = UserDefaults.standard.string(forKey: "userID")
        let savedRole = UserDefaults.standard.string(forKey: "userRole")
        let savedUsername = UserDefaults.standard.string(forKey: "username")

        if UserStore.shared.currentUserID == nil {
            UserStore.shared.currentUserID = savedUserID
            UserStore.shared.currentUserRole = savedRole
            UserStore.shared.currentUsername = savedUsername
            UserStore.shared.currentTechID = savedUserID
        }

        if let role = savedRole, !role.isEmpty {
            openHomeScreen(for: role)
        }
    }

    func setupPasswordToggle() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
        passwordTextField.rightView = button
        passwordTextField.rightViewMode = .always
    }

    @objc func togglePassword(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()

        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: imageName), for: .normal)

        if let text = passwordTextField.text {
            passwordTextField.text = ""
            passwordTextField.text = text
        }
    }

    @IBAction func LoginButton(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter email and password")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.showAlert(title: "Login Failed", message: error.localizedDescription)
                return
            }

            guard let uid = result?.user.uid else { return }
            self?.fetchUserRole(uid: uid)
        }
    }

    private func fetchUserRole(uid: String) {
        db.collection("Users").document(uid).getDocument { [weak self] snapshot, error in

            if let error = error {
                self?.showAlert(title: "Error", message: error.localizedDescription)
                return
            }

            guard let data = snapshot?.data(),
                  let role = data["Role"] as? String else {
                self?.showAlert(title: "Error", message: "User role not found")
                return
            }

            let username = data["Username"] as? String

            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.set(uid, forKey: "userID")
            UserDefaults.standard.set(role, forKey: "userRole")
            UserDefaults.standard.set(username, forKey: "username")

            UserStore.shared.currentUserID = uid
            UserStore.shared.currentUserRole = role
            UserStore.shared.currentUsername = username
            UserStore.shared.currentTechID = uid

            self?.openHomeScreen(for: role)
        }
    }

    private func openHomeScreen(for role: String) {
        let storyboardName: String

        switch role {
        case "Admin":
            storyboardName = "Admin"
        case "Student", "Staff":
            storyboardName = "StudStaff"
        case "Technician":
            storyboardName = "Technician"
        case "Manager":
            storyboardName = "TechManager"
        default:
            showAlert(title: "Access Denied", message: "Invalid role")
            return
        }

        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = storyboard.instantiateInitialViewController()!
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
