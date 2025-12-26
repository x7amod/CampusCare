//
//  UserItemView.swift
//  CampusCare
//
//  Created by dar on 26/12/2025.
//

import UIKit


class UserItemView: UIView {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    
    var onTap: (() -> Void)?

        static func instantiate() -> UserItemView {
            let nib = UINib(nibName: "UserItemView", bundle: nil)
            return nib.instantiate(withOwner: nil, options: nil).first as! UserItemView
        }

        func configure(with user: UserModel) {
            nameLabel.text = "\(user.FirstName) \(user.LastName)".trimmingCharacters(in: .whitespaces)
            usernameLabel.text = user.username
            roleLabel.text = user.Role
        }

        override func awakeFromNib() {
            super.awakeFromNib()
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
            addGestureRecognizer(tap)
            isUserInteractionEnabled = true
        }

        @objc private func didTap() {
            onTap?()
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

