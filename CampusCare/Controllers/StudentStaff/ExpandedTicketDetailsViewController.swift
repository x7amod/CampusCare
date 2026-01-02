//// OUT OF SERVICE FILE || UNUSED <<--------------------------------------------------------
////  ExpandedTicketDetailsViewController.swift
////  CampusCare
////
////  Created by m1 on 17/12/2025.
////
//import UIKit
//import FirebaseFirestore
//
//class ExpandedTicketDetailsViewController: UIViewController {
//    
//    @IBOutlet weak var statusView: UIView!
//    @IBOutlet weak var statusText: UILabel!
//    @IBOutlet weak var locationLabel: UILabel!
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var assignedDateLabel: UILabel!
//    @IBOutlet weak var assignedToLabel: UILabel!
//    @IBOutlet weak var requestCreatedDateLabel: UILabel!
//    @IBOutlet weak var inProgressLabel: UILabel!
//    @IBOutlet weak var inProgressDateLabel: UILabel!
//    @IBOutlet weak var requestCompleteLabel: UILabel!
//    @IBOutlet weak var requestCompleteDateLabel: UILabel!
//    @IBOutlet weak var technicianNameLabel: UILabel!
//    @IBOutlet weak var technicianPhoneNoLabel: UILabel!
//    @IBOutlet weak var callButton: UIButton!
//    @IBOutlet weak var feedbackButton: UIButton!
//    @IBOutlet weak var categoryLabel: UILabel!
//    @IBOutlet weak var modifyRequestButton: UIButton!
//    @IBOutlet weak var cancelRequestButton: UIButton!
//    @IBOutlet weak var descriptionLabel: UILabel!
//    
//    //Views outlets:
//    
//    @IBOutlet weak var mainVerticalView: UIStackView!
//    @IBOutlet weak var requestAssignedView: UIStackView!
//    @IBOutlet weak var requestInProgressView: UIStackView!
//    @IBOutlet weak var requestCompleteView: UIStackView!
//    @IBOutlet weak var technicianDetailsView: UIStackView!
//    @IBOutlet weak var feedbackBtnView: UIStackView!
//    @IBOutlet weak var modifyCancelBtnsView: UIStackView!
//    // receive data from the previous screen
//    var requestData: RequestModel?
//    let bulletPoint = "\u{2022} " // Unicode for bullet point
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Apply styling to all buttons
//        styleButton(callButton)
//        styleButton(feedbackButton)
//        styleButton(modifyRequestButton)
//        styleButton(cancelRequestButton)
//        
//        // Populate UI with request data
//        if let data = requestData {
//            populateRequestDetails(data)
//        }
//    }
//    
//    private func styleButton(_ button: UIButton) {
//        button.layer.cornerRadius = 14
//        button.layer.shadowColor = UIColor.black.cgColor
//        button.layer.shadowOpacity = 0.25
//        button.layer.shadowOffset = CGSize(width: 0, height: 2)
//        button.layer.shadowRadius = 3
//        button.layer.masksToBounds = false
//        button.layer.shadowPath = UIBezierPath(
//            roundedRect: button.bounds,
//            cornerRadius: 14
//        ).cgPath
//    }
//    
//    private func populateRequestDetails(_ request: RequestModel) {
//        // Basic info
//        titleLabel.text = request.title
//        locationLabel.text = bulletPoint + request.location
//        categoryLabel.text = request.category
//        statusText.text = request.status
//        descriptionLabel.text = request.description
//        
//        // Apply status styling
//        applyStatusStyling(status: request.status)
//        
//        // Date formatter
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .medium
//        dateFormatter.timeStyle = .short
//        
//        // Request created date (releaseDate from RequestModel)
//        requestCreatedDateLabel.text = dateFormatter.string(from: request.releaseDate.dateValue())
//        
//        // Assigned date (assignedDate from RequestModel - optional)
//        if let assignedDate = request.assignedDate {
//            assignedDateLabel.text = dateFormatter.string(from: assignedDate.dateValue())
//        } else {
//            assignedDateLabel.text = "Not assigned yet"
//        }
//        
//        // In-progress date - TODO: Add inProgressDate field to RequestModel/Firestore         inProgressDateLabel.text = "N/A"
//        
//        // Complete date - TODO: Add completedDate field to RequestModel/Firestore
//        requestCompleteDateLabel.text = "N/A"
//        
//        // Technician info - fetch from UsersCollection using assignTechID
//        if !request.assignTechID.isEmpty {
//            technicianNameLabel.text = "Loading..."
//            technicianPhoneNoLabel.text = "Loading..."
//            fetchTechnicianDetails(techID: request.assignTechID)
//        } else {
//            technicianNameLabel.text = "Not assigned"
//            technicianPhoneNoLabel.text = "N/A"
//        }
//        
//        // Apply business rules for view visibility based on status
//        applyBusinessRules(status: request.status)
//    }
//    
//    private func applyBusinessRules(status: String) {
//        // modifyCancelBtnsView: only visible if status is "New" or "Pending"
//        modifyCancelBtnsView.isHidden = !(status == "New" || status == "Pending")
//        
//        // feedbackBtnView: only visible if status is "Complete"
//        feedbackBtnView.isHidden = status != "Complete"
//        
//        // technicianDetailsView: only visible if status is NOT "Pending" or "New"
//        technicianDetailsView.isHidden = (status == "Pending" || status == "New")
//        
//        // requestAssignedView: visible if status has reached "Assigned" or beyond
//        requestAssignedView.isHidden = (status == "New" || status == "Pending")
//        
//        // requestInProgressView: visible if status has reached "In-Progress" or beyond
//        requestInProgressView.isHidden = !(status == "In-Progress" || status == "Complete")
//        
//        // requestCompleteView: visible only if status is "Complete"
//        requestCompleteView.isHidden = status != "Complete"
//    }
//    
//    
//    private func applyStatusStyling(status: String) {
//        statusView.layer.cornerRadius = 16
//        
//        switch status {
//        case "Pending":
//            statusView.backgroundColor = UIColor(red: 120/255, green: 120/255, blue: 120/255, alpha: 0.75)
//            statusText.textColor = .white
//            
//        case "In-Progress":
//            statusView.backgroundColor = UIColor(red: 14/255, green: 0.0, blue: 201/255, alpha: 1.0)
//            statusText.textColor = .white
//            
//        case "Complete":
//            statusView.backgroundColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1.0)
//            statusText.textColor = .white
//            
//        case "Assigned":
//            statusView.backgroundColor = UIColor(red: 230/255, green: 237/255, blue: 244/255, alpha: 1.0)
//            statusText.textColor = .black
//            
//        default:
//            statusView.backgroundColor = .lightGray
//            statusText.textColor = .black
//        }
//    }
//    
//    private func fetchTechnicianDetails(techID: String) {
//        let db = Firestore.firestore()
//        db.collection("Users").document(techID).getDocument { [weak self] (document, error) in
//            if let error = error {
//                print("Error fetching technician: \(error.localizedDescription)")
//                DispatchQueue.main.async {
//                    self?.technicianNameLabel.text = "Error loading"
//                    self?.technicianPhoneNoLabel.text = "N/A"
//                }
//                return
//            }
//            
//            if let document = document, document.exists {
//                let data = document.data()
//                let firstName = data?["firstName"] as? String ?? ""
//                let lastName = data?["lastName"] as? String ?? ""
//                let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
//                let phone = data?["phone"] as? String ?? data?["phoneNumber"] as? String ?? "N/A"
//                
//                DispatchQueue.main.async {
//                    self?.technicianNameLabel.text = fullName.isEmpty ? "Unknown" : fullName
//                    self?.technicianPhoneNoLabel.text = phone
//                }
//            } else {
//                DispatchQueue.main.async {
//                    self?.technicianNameLabel.text = "Not found"
//                    self?.technicianPhoneNoLabel.text = "N/A"
//                }
//            }
//        }
//    }
//    
//    @IBAction func callButtonTapped(_ sender: UIButton) {
//        guard let phoneNumber = technicianPhoneNoLabel.text, phoneNumber != "N/A", phoneNumber != "Loading..." else {
//            return
//        }
//        
//        // Remove non-numeric characters
//        let cleanedPhone = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
//        
//        if let url = URL(string: "tel://\(cleanedPhone)"), UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url)
//        }
//    }
//    
//    @IBAction func feedbackButtonTapped(_ sender: UIButton) {
//        // TODO: Implement feedback functionality
//        let alert = UIAlertController(title: "Feedback", message: "Feedback feature coming soon!", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
