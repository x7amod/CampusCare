//
//  editUserinfo.swift
//  CampusCare
//
//  Created by dar on 23/12/2025.
//


import UIKit
import FirebaseFirestore

final class editUserInfoController: UIViewController {

    var user: UserModel!

    @IBOutlet weak var firstnametext: UITextField!
    @IBOutlet weak var lastnametext: UITextField!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var Department: UITextField!
    @IBOutlet weak var roleButton: UIButton!

    private let usersCollection = UsersCollection()
    private var selectedRole: String? = nil

    private let roles = ["Student", "Staff", "Technician", "Manager"]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Update User Info"

        let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as! CampusCareHeader
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        view.addSubview(headerView)
        headerView.setTitle("Update User")

        guard let user = user else {
            assertionFailure("[editUserInfoController] user not set before presenting")
            navigationController?.popViewController(animated: true)
            return
        }

        firstnametext.text = user.FirstName
        lastnametext.text = user.LastName
        userNameField.text = user.username
        Department.text = user.Department

        let normalizedRole = normalizeRole(user.Role)
        selectedRole = normalizedRole

        
        if let normalizedRole, roles.contains(normalizedRole) {
            applyRoleButtonStyle(title: normalizedRole)
        } else {
            applyRoleButtonStyle(title: "Select")
        }

        setupRoleMenu()
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

        roleButton.configuration = config

        roleButton.backgroundColor = .systemBackground
        roleButton.layer.cornerRadius = 10
        roleButton.clipsToBounds = true
        roleButton.layer.borderWidth = 1
        roleButton.layer.borderColor = UIColor.separator.withAlphaComponent(0.3).cgColor

        roleButton.contentHorizontalAlignment = .fill
    }

    private func normalizeRole(_ role: String) -> String? {
        let trimmed = role.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }

        if let match = roles.first(where: { $0.lowercased() == trimmed.lowercased() }) {
            return match
        }

        return trimmed
    }

    private func setupRoleMenu() {
        let actions = roles.map { role in
            UIAction(title: role, state: (role == selectedRole ? .on : .off)) { [weak self] _ in
                guard let self else { return }
                self.selectedRole = role

                
                self.applyRoleButtonStyle(title: role)

                self.setupRoleMenu()
            }
        }

        roleButton.menu = UIMenu(title: "Select Role", children: actions)
        roleButton.showsMenuAsPrimaryAction = true
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Confirm",
            message: "Are you sure you want to save updates?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.performUpdate()
        })

        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        present(alert, animated: true)
    }

    private func performUpdate() {
        guard let user = user else { return }

        let first = (firstnametext.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let last  = (lastnametext.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let uname = (userNameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let dept  = (Department.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        let role = (selectedRole ?? normalizeRole(user.Role) ?? user.Role).trimmingCharacters(in: .whitespacesAndNewlines)

        if first.isEmpty || last.isEmpty || uname.isEmpty || dept.isEmpty || role.isEmpty {
            let a = UIAlertController(
                title: "Missing Info",
                message: "Please fill all fields before saving.",
                preferredStyle: .alert
            )
            a.addAction(UIAlertAction(title: "OK", style: .default))
            present(a, animated: true)
            return
        }

        let fields: [String: Any] = [
            "Username": uname,
            "Role": role,
            "First Name": first,
            "Last Name": last,
            "Department": dept
        ]

        usersCollection.updateUser(uid: user.id, fields: fields) { [weak self] success in
            guard let self else { return }

            DispatchQueue.main.async {
                if success {
                    let updatedUser = UserModel(
                        id: user.id,
                        username: uname,
                        Role: role,
                        FirstName: first,
                        LastName: last,
                        Department: dept
                    )

                    let okAlert = UIAlertController(
                        title: "Updated Successfully!",
                        message: nil,
                        preferredStyle: .alert
                    )

                    okAlert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                        self?.goBackToUserInfo(updatedUser: updatedUser)
                    })

                    self.present(okAlert, animated: true)
                } else {
                    let fail = UIAlertController(
                        title: "Update Failed",
                        message: "Please try again.",
                        preferredStyle: .alert
                    )
                    fail.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(fail, animated: true)
                }
            }
        }
    }

    private func goBackToUserInfo(updatedUser: UserModel) {
        if let nav = navigationController,
           let userInfoVC = nav.viewControllers.first(where: { $0 is UserInfoViewController }) as? UserInfoViewController {

            userInfoVC.user = updatedUser
            nav.popToViewController(userInfoVC, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}
