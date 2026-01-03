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

        configurePasswordField(userPasswordTextField)
        configurePasswordField(confirmPassword)

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

    private func configurePasswordField(_ textField: UITextField) {
        textField.isSecureTextEntry = true
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.smartDashesType = .no
        textField.smartQuotesType = .no
        textField.spellCheckingType = .no
        textField.textContentType = .oneTimeCode

        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .systemGray
        button.frame = CGRect(x: 0, y: 0, width: 34, height: 30)
        button.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 30))
        button.center = CGPoint(x: container.bounds.width - 18, y: container.bounds.height / 2)
        container.addSubview(button)

        textField.rightView = container
        textField.rightViewMode = .always
    }

    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        guard
            let container = sender.superview,
            let textField = container.superview as? UITextField
        else { return }

        let wasFirstResponder = textField.isFirstResponder
        let currentText = textField.text

        textField.isSecureTextEntry.toggle()
        sender.setImage(UIImage(systemName: textField.isSecureTextEntry ? "eye.slash" : "eye"), for: .normal)

        textField.text = ""
        textField.text = currentText

        if wasFirstResponder {
            textField.becomeFirstResponder()
        }
    }

    private func applyRoleButtonStyle(title: String) {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = .label
        config.titleAlignment = .leading
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)

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
                self.setupRoleMenu()
            }
        }

        roleBtn.menu = UIMenu(title: "Select Role", options: .singleSelection, children: actions)
        roleBtn.showsMenuAsPrimaryAction = true
    }

    private func isStrongPassword(_ password: String) -> Bool {
        guard password.count >= 6 else { return false }
        let hasUpper = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLower = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSymbol = password.range(of: "[!@#$%*.]", options: .regularExpression) != nil
        return hasUpper && hasLower && hasNumber && hasSymbol
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
            return
        }

        if !password.isEmpty && !isStrongPassword(password) {
            confirmPasswordErrorLabel.text = "Password must be at least 6 characters and include uppercase, lowercase, number, and symbol (! @ # $ % * .)"
            confirmPasswordErrorLabel.isHidden = false
            return
        }

        confirmPasswordErrorLabel.text = ""
        confirmPasswordErrorLabel.isHidden = true
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

        guard isStrongPassword(password) else {
            showAlert(title: "Add User", message: "Password must be at least 6 characters and include uppercase, lowercase, number, and symbol (! @ # $ % * .)")
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

        let confirmAlert = UIAlertController(
            title: "Confirm",
            message: "Are you sure you want to add this user?\n\nEmail: \(email)\nRole: \(role)",
            preferredStyle: .alert
        )

        confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.createUser(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password,
                department: department,
                role: role
            )
        })

        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(confirmAlert, animated: true)
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

                let success = UIAlertController(title: "User Successfully Added!", message: nil, preferredStyle: .alert)
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
