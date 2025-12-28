//
//  AddUser.swift
//  CampusCare
//
//  Created by dar on 23/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class AddUserViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var departmentTextField: UITextField!
    @IBOutlet weak var roleBtn: UIButton!

    private let db = FirestoreManager.shared.db
    private var selectedRole: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add User"

        
        let headerView = Bundle.main
            .loadNibNamed("CampusCareHeader", owner: nil, options: nil)?
            .first as! CampusCareHeader

        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        view.addSubview(headerView)
        headerView.setTitle("Add User")

        
        roleBtn.setTitle("Select", for: .normal)
        setupRoleMenu()
    }

    
    private func setupRoleMenu() {
        let roles = ["Student", "Staff", "Technician", "Manager"]

        let actions = roles.map { role in
            UIAction(
                title: role,
                state: (role == selectedRole ? .on : .off)
            ) { [weak self] _ in
                guard let self else { return }
                self.selectedRole = role
                self.roleBtn.setTitle(role, for: .normal)
                self.setupRoleMenu()   // refresh checkmarks
            }
        }

        roleBtn.menu = UIMenu(title: "Select Role", children: actions)
        roleBtn.showsMenuAsPrimaryAction = true
    }

    

    @IBAction func AddUserButton(_ sender: UIButton) {

        let firstName = (firstNameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName  = (lastNameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let username  = (userNameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password  = (userPasswordTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let department = (departmentTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !firstName.isEmpty,
              !lastName.isEmpty,
              !username.isEmpty,
              !password.isEmpty,
              !department.isEmpty else {
            showAlert("Please fill all fields")
            return
        }

        
        guard let role = selectedRole else {
            showAlert("Please select a role")
            return
        }

      
        let confirm = UIAlertController(
            title: "Confirm",
            message: "Are you Sure You Want to Add this User?",
            preferredStyle: .alert
        )

        confirm.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.createUser(
                firstName: firstName,
                lastName: lastName,
                username: username,
                password: password,
                department: department,
                role: role
            )
        })

        confirm.addAction(UIAlertAction(title: "No", style: .cancel))
        present(confirm, animated: true)
    }

    private func createUser(firstName: String,
                            lastName: String,
                            username: String,
                            password: String,
                            department: String,
                            role: String) {

        
        let email = username.lowercased()

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self else { return }

            if let error = error {
                self.showAlert(error.localizedDescription)
                return
            }

            guard let uid = result?.user.uid else {
                self.showAlert("Failed to create user")
                return
            }

            let data: [String: Any] = [
                "Username": username,
                "Role": role,
                "First Name": firstName,
                "Last Name": lastName,
                "Department": department
            ]

            self.db.collection("Users").document(uid).setData(data) { error in
                if let error = error {
                    self.showAlert(error.localizedDescription)
                    return
                }

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

   

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Add User", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
