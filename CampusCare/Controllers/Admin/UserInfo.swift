//
//  UserInfo.swift
//  CampusCare
//
//  Created by dar on 23/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class UserInfoViewController: UIViewController {
    
    var user: UserModel?
    private let usersCollection = UsersCollection()
    
    @IBOutlet weak var Stackview: UIStackView!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var roleField: UITextField!
    @IBOutlet weak var departmentField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "User Info"
        applyUserToUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyUserToUI()
    }
    
    private func applyUserToUI() {
        guard let user = user else {
            print("[UserInfo] user is nil")
            return
        }
        
        firstName.text = user.FirstName
        lastName.text = user.LastName
        userNameField.text = user.username
        roleField.text = user.Role
        departmentField.text = user.Department
    }
    
    //update button
    @IBAction func updateTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Admin", bundle: nil)
        
        guard let editVC = storyboard.instantiateViewController(
            withIdentifier: "editUserInfoController"
        ) as? editUserInfoController else {
            print("[UserInfo] Could not instantiate editUserInfoController")
            return
        }
        
        guard let user = user else {
            print("[UserInfo] user is nil, cannot open edit page")
            return
        }
        
        editVC.user = user
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    //delete button
    @IBAction func deleteTapped(_ sender: UIButton) {
        let confirm = UIAlertController(
            title: "Confirm",
            message: "Are you sure you want to delete this user?",
            preferredStyle: .alert
        )
        
        
        confirm.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.performDelete()
        })
        
        
        confirm.addAction(UIAlertAction(title: "No", style: .cancel))
        
        present(confirm, animated: true)
    }

    private func performDelete() {
        guard let user = user else {
            print("[UserInfo] user is nil, cannot delete")
            return
        }

        usersCollection.deleteUserDocument(uid: user.id) { [weak self] success in
            guard let self else { return }
            
            DispatchQueue.main.async {
                if success {
                    let successAlert = UIAlertController(
                        title: "This User Was Successfully Deleted!",
                        message: nil,
                        preferredStyle: .alert
                    )

                    successAlert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                       
                        self?.navigationController?.popViewController(animated: true)
                    })

                    self.present(successAlert, animated: true)
                } else {
                    let failAlert = UIAlertController(
                        title: "Delete Failed",
                        message: "Please try again",
                        preferredStyle: .alert
                    )
                    failAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(failAlert, animated: true)
                }
            }
        }
    }
}
