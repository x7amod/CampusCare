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

    var user: UserModel!

    @IBOutlet weak var Stackview: UIStackView!
    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    
    @IBOutlet weak var roleField: UITextField!
    @IBOutlet weak var departmentField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title="User Info"
        // Fill UI from the selected user
        firstName.text = user.FirstName
       lastName.text = user.LastName
       userNameField.text = user.username
      roleField.text = user.Role
      departmentField.text = user.Department
    }
}

