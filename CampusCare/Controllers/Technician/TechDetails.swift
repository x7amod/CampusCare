//
//  TechDetails.swift
//  CampusCare
//
//  Reem on 22/12/2025.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore


class TechDetails: UIViewController {
    
    //mac n cheese
    var request: RequestModel?
    private var selectedStatus: String? //chocomint
    private let requestCollection = RequestCollection()
    
    //components
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskLocation: UILabel!
    @IBOutlet weak var subDate: UILabel! //release date ?
    @IBOutlet weak var taskDescription: UILabel!
    @IBOutlet weak var taskCategory: UILabel!
    @IBOutlet weak var taskImg: UIImageView!
    @IBOutlet weak var taskStatus: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI first (optional styling)
        setupUI()
        
        
        
        populateData()
        setupStatusButton()
        
        
        
        
    }//pepsi
    
    
    
    
    
    
    private func loadImage(from urlString: String) { //mac n cheese
        guard let url = URL(string: urlString) else { return }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.taskImg.image = image
                }
            }
        }
    }
    
    
    
    
    private func setupUI() {
        // Basic styling
        taskImg.layer.cornerRadius = 8
        taskImg.clipsToBounds = true
        taskStatus.layer.cornerRadius = 8
        taskStatus.clipsToBounds = true
        
        // Save button styling
        saveBtn.layer.cornerRadius = 8
        saveBtn.clipsToBounds = true
        
        // Set initial selectedStatus from request
        selectedStatus = request?.status
    }
    
    private func setupStatusButton() {
        // Configure the dropdown menu
        let statuses = ["In-Progress", "Complete", "Escalated"]//fry
        
        var menuChildren: [UIMenuElement] = []
        
        for status in statuses {
            let action = UIAction(title: status) { [weak self] _ in
                self?.statusSelected(status)
            }
            menuChildren.append(action)
        }
        
        let menu = UIMenu(title: "Update Status", children: menuChildren)
        taskStatus.menu = menu
        taskStatus.showsMenuAsPrimaryAction = true
        
        // Update button appearance based on current status
        updateStatusButtonAppearance()
    }
    private func statusSelected(_ status: String) {
        //water
        guard let currentStatus = request?.status else { return }
        
        if currentStatus == "Assigned" && status == "Complete" {
            let alert = UIAlertController(
                title: "Invalid Status Change",
                message: "Must set to 'In-Progress' first before marking Complete.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        
        selectedStatus = status
        taskStatus.setTitle("\(status)", for: .normal)
        updateStatusButtonAppearance()
        
        // Enable save button since a change was made
        saveBtn.isEnabled = true
        saveBtn.backgroundColor = .buttons
    }
    
    private func updateStatusButtonAppearance() {
        guard let status = selectedStatus else { return }
        
        // Set color based on status
        switch status.lowercased() {
        case "new", "assigned":
            taskStatus.backgroundColor = UIColor(red: 120/255 , green:(120/255), blue:(120/255), alpha: 0.75) //light gray
        case "in progress", "in-progress":
            taskStatus.backgroundColor = UIColor(red: 14/255 , green:0.0, blue:(201/255), alpha: 1.0) //deep blue
        case "complete", "completed":
            taskStatus.backgroundColor = UIColor(red: 52/255 , green:(199/255), blue:(89/255), alpha: 1.0) //green
        case "escalated":
            taskStatus.backgroundColor = .systemRed
        default:
            taskStatus.backgroundColor = .systemGray
        }
        
        // Set text color for contrast
        taskStatus.setTitleColor(.white, for: .normal)
    }
    
    
    
    
    
    private func populateData() {
        
        guard let request = request else {
            print("No request data")
            return
        }
        
        
        
        
        // Set text values
        taskTitle.text = request.title
        taskLocation.text = request.location
        taskDescription.text = request.description
        taskCategory.text = request.category
        
        // Format and set dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        subDate.text = "Released: \(dateFormatter.string(from: request.releaseDate.dateValue()))"
        
        // Set status button
        taskStatus.setTitle("Status: \(request.status)", for: .normal) //cheesecake
        
        //selectedStatus = request.status //chocomint
        // Set status button initial state
        taskStatus.setTitle("\(request.status)", for: .normal)
        selectedStatus = request.status
        updateStatusButtonAppearance()
        
        
        
        
        
        
        
        if !request.imageURL.isEmpty {
            loadImage(from: request.imageURL)
        } else {
            taskImg.image = UIImage(named: "cloudinary_logo")
            taskImg.window?.safeAreaAspectFitLayoutGuide.widthAnchor.constraint(equalToConstant: 100).isActive = true
            //taskImg.image = UIImage(systemName:"cloudinary_logo") //kitkat
            //taskImg.contentMode = .scaleAspectFit
            //  taskImg.tintColor = .lightGray
            
        }
        
        
        
        
        //initailly disable save - chocomint
        saveBtn.isEnabled = false
        saveBtn.backgroundColor = UIColor(red: 120/255 , green:(120/255), blue:(120/255), alpha: 0.75)
        //
        
        
    }
    
    //actions
    
    
    @IBAction func saveButtontapped(_ sender: UIButton) {
        guard let request = request,
              let newStatus = selectedStatus,
              newStatus != request.status else {
            
            // No changes made
            let alert = UIAlertController(
                title: "No Changes",
                message: "Status hasn't been changed.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        //fry - prevent status from going back to assign
        // if newStatus == "Assigned" {
        //      let alert = UIAlertController(
        //        title: "Invalid Status",
        //      message: "Cannot set status back to 'Assigned'.",
        //    preferredStyle: .alert
        //)
        //alert.addAction(UIAlertAction(title: "OK", style: .default))
        //present(alert, animated: true)
        //return
        //}
        
        
        
        
        
        // Show loading indicator
        let loadingAlert = UIAlertController(
            title: "Saving...",
            message: nil,
            preferredStyle: .alert
        )
        present(loadingAlert, animated: true)
        
        // Prepare update data
        var updateData: [String: Any] = [
            "status": newStatus,
            "lastUpdateDate": Timestamp(date: Date())
        ]
        
        // Add specific date fields based on status
        if newStatus == "In Progress" || newStatus == "In-Progress" {
            updateData["inProgressDate"] = Timestamp(date: Date())
        } else if newStatus == "Complete" {
            updateData["completedDate"] = Timestamp(date: Date())
        }
        
        updateRequestInFirebase(requestID: request.id, updateData: updateData, loadingAlert: loadingAlert)
        
    }
    
    
    //blueberry good
    private func updateRequestInFirebase(requestID: String, updateData: [String: Any], loadingAlert: UIAlertController) {
        let db = Firestore.firestore()
        
        print("DEBUG: Updating request \(requestID) with data: \(updateData)")
        
        db.collection("Requests").document(requestID).updateData(updateData) { [weak self] error in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    if let error = error {
                        // Show error
                        print("DEBUG: Firebase update error: \(error)")
                        let errorAlert = UIAlertController(
                            title: "Update Failed",
                            message: error.localizedDescription,
                            preferredStyle: .alert
                        )
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(errorAlert, animated: true)
                    } else {
                        print("DEBUG: Firebase update successful")
                        
                        // Success - update local request
                        let newStatus = updateData["status"] as? String ?? ""
                        self?.request?.status = newStatus
                        
                        // Notify request creator of status update
                        if let request = self?.request {
                            self?.notifyCreatorOfStatusUpdate(
                                requestID: request.id,
                                requestTitle: request.title,
                                creatorID: request.creatorID,
                                newStatus: newStatus
                            )
                        }
                        
                        // Disable save button again
                        self?.saveBtn.isEnabled = false
                        self?.saveBtn.backgroundColor = UIColor(red: 120/255, green: 120/255, blue: 120/255, alpha: 0.75)
                        
                        // Show success message
                        let successAlert = UIAlertController(
                            title: "Success!",
                            message: "Status updated to \(updateData["status"] as? String ?? "")",
                            preferredStyle: .alert
                        )
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                            // Optionally go back to list
                            self?.navigationController?.popViewController(animated: true)
                        })
                        self?.present(successAlert, animated: true)
                        
                        // Update button appearance
                        self?.updateStatusButtonAppearance()
                    }
                }
            }
        }
    }
    
    // MARK: - Notification Helper
    
    /// Notify request creator when status is updated
    private func notifyCreatorOfStatusUpdate(requestID: String, requestTitle: String, creatorID: String, newStatus: String) {
        let usersCollection = UsersCollection.shared
        let notificationsCollection = NotificationsCollection()
        
        // Get technician ID (current user)
        guard let techID = Auth.auth().currentUser?.uid else {
            print("[TechDetails] No logged in technician to get name from")
            return
        }
        
        // Fetch technician's full name
        usersCollection.fetchUserFullName(userID: techID) { techName in
            let technicianName = techName ?? "The technician"
            
            let title: String
            let body: String
            
            if newStatus == "In-Progress" || newStatus == "In Progress" {
                title = "\(requestTitle) is now In-Progress"
                body = "\(technicianName) has started working on your request."
            } else if newStatus == "Complete" {
                title = "\(requestTitle) is now Complete"
                body = "\(technicianName) has marked your request as Complete."
            } else {
                // Unknown status, don't send notification
                print("[TechDetails] Unknown status '\(newStatus)', skipping notification")
                return
            }
            
            // Notify request creator
            notificationsCollection.createNotification(
                userID: creatorID,
                title: title,
                body: body,
                type: newStatus,
                requestID: requestID
            ) { result in
                if case .failure(let error) = result {
                    print("[TechDetails] Failed to notify creator: \(error.localizedDescription)")
                } else {
                    print("[TechDetails] Creator notified of status update to \(newStatus)")
                }
            }
        }
    }
    
}
