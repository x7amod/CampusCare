//
//  LoginViewController.swift
//  CampusCare
//
//  Created by BP-36-201-14 on 29/11/2025.


import UIKit
import FirebaseAuth
import FirebaseFirestore

class Login: UIViewController {
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let db = Firestore.firestore()

    @IBAction func LoginButton(_ sender: UIButton) {
    
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter email and password")
            return
    }
    
    
        // Firebase Authentication
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.showAlert(title: "Login Failed", message: error.localizedDescription)
                return
            }

            guard let uid = result?.user.uid else { return }

            // Get user role from Firestore
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

            //added by reem to store tech id
            UserStore.shared.currentUserID = uid
                    UserStore.shared.currentUserRole = role
                    UserStore.shared.currentUsername = data["Username"] as? String
                    UserStore.shared.currentTechID = uid
            ////////
            
            
            
            
            // Route user by role
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

    
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Error", message: "Enter your email first")
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                self?.showAlert(title: "Email Sent", message: "Password reset email sent")
        }
        }
        
        
        
    }
}
