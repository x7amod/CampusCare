//
//  AddUser.swift
//  CampusCare
//
//  Created by dar on 23/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore

final class AddUserViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var departmentTextField: UITextField!
    @IBOutlet weak var roleBtn: UIButton!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!

    private let db = Firestore.firestore()
    private var selectedRole: String? = nil

    private lazy var secondaryAuth: Auth = {
        return SecondaryFirebase.auth
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add New User"

        // Password secure
        userPasswordTextField.isSecureTextEntry = true
        confirmPassword.isSecureTextEntry = true

        confirmPasswordErrorLabel.text = ""
        confirmPasswordErrorLabel.textColor = .systemRed
        confirmPasswordErrorLabel.isHidden = true

        userPasswordTextField.addTarget(self, action: #selector(passwordFieldsChanged), for: .editingChanged)
        confirmPassword.addTarget(self, action: #selector(passwordFieldsChanged), for: .editingChanged)

        
        applyRoleButtonStyle(title: "Select")
        setupRoleMenu()
    }

    
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        
        let current = selectedRole ?? "Select"
        applyRoleButtonStyle(title: current)
    }

   
    private func applyRoleButtonStyle(title: String) {

        var config = UIButton.Configuration.plain()

        
        config.title = title
        config.baseForegroundColor = .label
        config.titleAlignment = .leading

        
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 8

        
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 12,
            leading: 12,
            bottom: 12,
            trailing: 12
        )

        roleBtn.configuration = config

       
        roleBtn.backgroundColor = .systemBackground
        roleBtn.layer.cornerRadius = 10
        roleBtn.clipsToBounds = true

        
        roleBtn.layer.borderWidth = 1
        roleBtn.layer.borderColor = UIColor.separator.withAlphaComponent(0.3).cgColor

       
        roleBtn.contentHorizontalAlignment = .fill
    }



    private func setupRoleMenu() {
        let roles = ["Student", "Staff", "Technician", "Manager"]

        let actions = roles.map { role in
            UIAction(title: role, state: (role == selectedRole ? .on : .off)) { [weak self] _ in
                guard let self else { return }
                self.selectedRole = role
                self.applyRoleButtonStyle(title: role)
                self.setupRoleMenu() // refresh checkmarks
            }
        }

        roleBtn.menu = UIMenu(title: "Select Role", options: .singleSelection, children: actions)
        roleBtn.showsMenuAsPrimaryAction = true
    }

    
    @objc private func passwordFieldsChanged() {
        let password = (userPasswordTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let confirm  = (confirmPassword.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if confirm.isEmpty {
            confirmPasswordErrorLabel.text = ""
            confirmPasswordErrorLabel.isHidden = true
            return
        }

        if password != confirm {
            confirmPasswordErrorLabel.text = "Password is different from User Password"
            confirmPasswordErrorLabel.isHidden = false
        } else {
            confirmPasswordErrorLabel.text = ""
            confirmPasswordErrorLabel.isHidden = true
        }
    }

  
    @IBAction func AddUserButton(_ sender: UIButton) {

        let firstName = (firstNameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName  = (lastNameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let email     = (userNameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let password  = (userPasswordTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmPw = (confirmPassword.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let department = (departmentTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              !confirmPw.isEmpty,
              !department.isEmpty else {
            showAlert(title: "Add User", message: "Please fill all fields")
            return
        }

        guard email.contains("@"), email.contains(".") else {
            showAlert(title: "Add User", message: "Enter a valid email in Username field")
            return
        }

        guard password.count >= 6 else {
            showAlert(title: "Add User", message: "Password must be at least 6 characters")
            return
        }

        guard password == confirmPw else {
            confirmPasswordErrorLabel.text = "Password is different from User Password"
            confirmPasswordErrorLabel.isHidden = false
            confirmPassword.becomeFirstResponder()
            return
        }

        guard let role = selectedRole else {
            showAlert(title: "Add User", message: "Please select a role")
            return
        }

        let confirm = UIAlertController(
            title: "Confirm",
            message: "Are you sure you want to add this user?\n\nEmail: \(email)\nRole: \(role)",
            preferredStyle: .alert
        )

        confirm.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.createUser(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password,
                department: department,
                role: role
            )
        })

        confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(confirm, animated: true)
    }

    private func createUser(firstName: String,
                            lastName: String,
                            email: String,
                            password: String,
                            department: String,
                            role: String) {

        secondaryAuth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self else { return }

            if let error = error {
                self.showAlert(title: "Add User", message: error.localizedDescription)
                return
            }

            guard let uid = result?.user.uid else {
                self.showAlert(title: "Add User", message: "Failed to create user")
                return
            }

            let data: [String: Any] = [
                "Username": email,
                "Role": role,
                "First Name": firstName,
                "Last Name": lastName,
                "Department": department
            ]

            self.db.collection("Users").document(uid).setData(data) { [weak self] error in
                guard let self else { return }

                if let error = error {
                    self.showAlert(title: "Add User", message: error.localizedDescription)
                    return
                }

                try? self.secondaryAuth.signOut()

                let success = UIAlertController(
                    title: "User Successfully Added!",
                    message: nil,
                    preferredStyle: .alert
                )
                success.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                })
                self.present(success, animated: true)
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
