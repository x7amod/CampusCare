//
//  editUserinfo.swift
//  CampusCare
//
//  Created by dar on 25/12/2025.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

final class editUserInfoController: UIViewController{
    
    var user: UserModel!
        
    @IBOutlet weak var firstnametext: UITextField!
    
    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var lastnametext: UITextField!
    
    @IBOutlet weak var roleButton: UIButton!
    @IBOutlet weak var RoleSelect: UIMenu!
    
    @IBOutlet weak var Department: UITextField!
   
     private var selectedRole = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title="User Info"
        setupBackButton()

        selectedRole = user.Role
        setupRoleMenu()
        // Fill UI from the selected user
        firstnametext.text = user.FirstName
        lastnametext.text = user.LastName
        userNameField.text = user.username
        Department.text = user.Department
        
        
    }
    // Back Button
    private func setupBackButton() {
        let backButton = UIButton(type: .system)
        backButton.frame = CGRect(x: 16, y: 50, width: 60, height: 30)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.systemBackground, for: .normal)
        backButton.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        view.addSubview(backButton)
    }

    @objc private func closeVC() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    
    private func setupRoleMenu() {
        let roles = ["Admin", "Technician Manager", "Staff", "Technician", "Student"]

        roleButton.setTitle(selectedRole, for: .normal)

        roleButton.menu = UIMenu(title: "Role", children: roles.map { role in
            UIAction(title: role, state: role == selectedRole ? .on : .off) { [weak self] _ in
                if role == "Technician Manager"{
                    self?.selectedRole = "TechManager" } else {
                        self?.selectedRole = role }
                    self?.setupRoleMenu() //
                }
                

        })

        roleButton.showsMenuAsPrimaryAction = true
    }
    
    
}
