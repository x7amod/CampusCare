//
//  ForgetPassword.swift
//  CampusCare
//
//  Created by dar on 25/12/2025.
//


import UIKit
import FirebaseAuth
import FirebaseFirestore


final class ForgetPassword: UIViewController{
    
    
    @IBOutlet weak var forgetPasswordText: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupHeader()
        setupBackButton()
        
        
    }
    private func setupHeader() {
        let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as! CampusCareHeader
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        view.addSubview(headerView)
        headerView.setTitle("Forget Password")
    }
    
    private func setupBackButton() {
        let backButton = UIButton(type: .system)
        backButton.frame = CGRect(x: 16, y: 50, width: 60, height: 30)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.systemBackground, for: .normal)
        backButton.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        view.addSubview(backButton)
    }
    
    @objc private func closeVC() {
        dismiss(animated: true)
    }
    
    
    @IBAction func forgetPasswordTapped(_ sender: UIButton) {
        
        let email = forgetPasswordText.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !email.isEmpty else { self.messageLabel.text = "Please enter email"; return }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.messageLabel.text = error.localizedDescription
                    self.messageLabel.textColor = .systemRed
                } else {
                    self.messageLabel.text = "Password reset email sent"
                    self.messageLabel.textColor = .systemGray2
                }
            }
            
        }
    }
    
    
}
