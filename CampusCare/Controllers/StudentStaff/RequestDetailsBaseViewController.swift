//
//  RequestDetailsBaseViewController.swift
//  CampusCare
//
//  Created by GitHub Copilot on 31/12/2025.
//

import UIKit
import FirebaseFirestore

class RequestDetailsBaseViewController: UIViewController {
    
    // MARK: - Common Properties
    var requestData: RequestModel?
    let bulletPoint = "\u{2022} " // Unicode for bullet point
    
    // MARK: - Shared Functions
    func styleButton(_ button: UIButton) {
        button.layer.cornerRadius = 14
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 3
        button.layer.masksToBounds = false
        button.layer.shadowPath = UIBezierPath(
            roundedRect: button.bounds,
            cornerRadius: 14
        ).cgPath
    }
    
    func createDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }
    
    func applyStatusStyling(to statusView: UIView, statusLabel: UILabel, status: String) {
        statusView.layer.cornerRadius = 16
        
        switch status {
        case "Pending":
            statusView.backgroundColor = UIColor(red: 120/255, green: 120/255, blue: 120/255, alpha: 0.75)
            statusLabel.textColor = .white
            
        case "In-Progress":
            statusView.backgroundColor = UIColor(red: 14/255, green: 0.0, blue: 201/255, alpha: 1.0)
            statusLabel.textColor = .white
            
        case "Complete":
            statusView.backgroundColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1.0)
            statusLabel.textColor = .white
            
        case "Assigned":
            statusView.backgroundColor = UIColor(red: 230/255, green: 237/255, blue: 244/255, alpha: 1.0)
            statusLabel.textColor = .black
        
        case "Escalated":
            statusView.backgroundColor = .systemRed
            statusLabel.textColor = .black
        
        default:
            statusView.backgroundColor = .lightGray
            statusLabel.textColor = .black
        }
    }
    
    func loadImageOnButton(from urlString: String?, button: UIButton) {
        guard
            let urlString = urlString,
            !urlString.isEmpty,
            let url = URL(string: urlString)
        else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                button.setImage(image, for: .normal)
                button.setTitle("", for: .normal)
                button.imageView?.contentMode = .scaleAspectFill
                button.clipsToBounds = true
                button.layer.cornerRadius = 20
            }
        }.resume()
    }
    
    func fetchTechnicianDetails(techID: String, nameLabel: UILabel, phoneLabel: UILabel) {
        UsersCollection.shared.fetchUserFullName(userID: techID) { fullName in
            DispatchQueue.main.async {
                if let fullName = fullName, !fullName.isEmpty {
                    nameLabel.text = fullName
                } else {
                    nameLabel.text = "Unknown"
                    print("[RequestDetailsVC] Error:Failed to fetch Tech Full Name! (Either Empty or Failed)")
                }
            }
        }
        
        // no phone number in db so disabled :)
        /*
        UsersCollection.shared.getUserInfo(uid: techID) { data in
            DispatchQueue.main.async {
                if let data = data {
                    let firstName = data["firstName"] as? String ?? ""
                    let lastName = data["lastName"] as? String ?? ""
                    let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                    let phone = data["phone"] as? String ?? data["phoneNumber"] as? String ?? "N/A"
                    
                    nameLabel.text = fullName.isEmpty ? "Unknown" : fullName
                    phoneLabel.text = phone
                } else {
                    nameLabel.text = "Not found"
                    phoneLabel.text = "N/A"
                }
            }
        }
        */
    }
    // no user phone number so all these are useless -_-
    func makePhoneCall(phoneLabel: UILabel) {
        guard let phoneNumber = phoneLabel.text,
              phoneNumber != "N/A",
              phoneNumber != "Loading..." else {
            return
        }
        
        // Remove non-numeric characters
        let cleanedPhone = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if let url = URL(string: "tel://\(cleanedPhone)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
        
    
}
