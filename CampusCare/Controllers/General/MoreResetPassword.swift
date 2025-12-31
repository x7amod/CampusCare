//
//  MoreResetPassword.swift
//  CampusCare
//
//  Created by dar on 31/12/2025.
//

import UIKit
import FirebaseAuth

class ResetPassword: UIViewController {

    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var resetPasswordbtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Reset Password"
        setupUI()
        wireEvents()
        updateResetButtonState()
    }

    private func setupUI() {
        configurePasswordField(currentPasswordTextField)
        configurePasswordField(newPasswordTextField)
        configurePasswordField(confirmPasswordTextField)

        currentPasswordTextField.returnKeyType = .next
        newPasswordTextField.returnKeyType = .next
        confirmPasswordTextField.returnKeyType = .done

        resetPasswordbtn.layer.cornerRadius = 14
        resetPasswordbtn.clipsToBounds = true
    }

    
    private func configurePasswordField(_ textField: UITextField) {
        textField.isSecureTextEntry = true
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none

        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .systemGray
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)

       
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 56, height: 30))
        
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

        textField.isSecureTextEntry.toggle()

        let imageName = textField.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }


    private func wireEvents() {
        [currentPasswordTextField, newPasswordTextField, confirmPasswordTextField].forEach {
            $0?.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
            $0?.delegate = self
        }
    }

    @objc private func textDidChange() {
        updateResetButtonState()
    }

    private func updateResetButtonState() {
        let current = currentPasswordTextField.text ?? ""
        let newPass = newPasswordTextField.text ?? ""
        let confirm = confirmPasswordTextField.text ?? ""

        let valid = !current.isEmpty && newPass.isStrongPassword && newPass == confirm
        resetPasswordbtn.isEnabled = valid
        resetPasswordbtn.alpha = valid ? 1.0 : 0.5
    }

    @IBAction func resetTapped(_ sender: UIButton) {
        view.endEditing(true)

        let currentPassword = currentPasswordTextField.text ?? ""
        let newPassword = newPasswordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""

        guard !currentPassword.isEmpty else {
            showAlert("Please enter your current password.")
            return
        }

        guard newPassword.isStrongPassword else {
            showAlert("Password must be at least 6 characters and include uppercase, lowercase, number, and symbol.")
            return
        }

        guard newPassword == confirmPassword else {
            showAlert("Confirm Password must match New Password.")
            return
        }

        setLoading(true)
        changePasswordInFirebase(currentPassword: currentPassword, newPassword: newPassword)
    }

    private func changePasswordInFirebase(currentPassword: String, newPassword: String) {

        guard let user = Auth.auth().currentUser else {
            setLoading(false)
            showAlert("No logged-in user.")
            return
        }

        guard let email = user.email else {
            setLoading(false)
            showAlert("No email found for current user.")
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)

        user.reauthenticate(with: credential) { [weak self] _, error in
            guard let self else { return }

            if let error = error {
                self.setLoading(false)
                self.showFirebaseError(error)
                return
            }

            user.updatePassword(to: newPassword) { [weak self] error in
                guard let self else { return }

                self.setLoading(false)

                if let error = error {
                    self.showFirebaseError(error)
                    return
                }

                if let uid = UsersCollection.shared.getCurrentUserId() {
                    UsersCollection.shared.updatePasswordLastChanged(uid: uid) { _ in }
                }

                self.showAlert("Password updated successfully!") { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    private func setLoading(_ isLoading: Bool) {
        resetPasswordbtn.isEnabled = !isLoading
        resetPasswordbtn.alpha = isLoading ? 0.6 : 1.0
        if !isLoading { updateResetButtonState() }
    }

    private func showFirebaseError(_ error: Error) {
        let nsError = error as NSError
        let code = AuthErrorCode(rawValue: nsError.code)

        let message: String
        switch code {
        case .wrongPassword, .invalidCredential:
            message = "Current password is incorrect."
        case .weakPassword:
            message = "The new password is too weak."
        case .requiresRecentLogin:
            message = "Please login again and try resetting your password."
        default:
            message = error.localizedDescription
        }

        showAlert(message)
    }

    private func showAlert(_ message: String, onOK: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Reset Password",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in onOK?() })
        present(alert, animated: true)
    }
}


extension ResetPassword: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case currentPasswordTextField:
            newPasswordTextField.becomeFirstResponder()
        case newPasswordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
            if resetPasswordbtn.isEnabled {
                resetTapped(resetPasswordbtn)
            }
        }
        return true
    }
}


private extension String {
    var isStrongPassword: Bool {
        guard count >= 6 else { return false }

        let hasUpper = range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLower = range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumber = range(of: "[0-9]", options: .regularExpression) != nil
        let hasSymbol = range(of: "[!,@,#,$,*,.]", options: .regularExpression) != nil

        return hasUpper && hasLower && hasNumber && hasSymbol
    }
}
