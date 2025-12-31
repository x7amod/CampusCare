//
//  InProgressRequestVC.swift
//  CampusCare
//
//  Created by m1 on 31/12/2025.
//

import UIKit

class InProgressRequestVC: RequestDetailsBaseViewController {
    
    // MARK: - IBOutlets specific to InProgressRequestPage
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var requestCreatedDateLabel: UILabel!
    @IBOutlet weak var assignedDateLabel: UILabel!
    @IBOutlet weak var assignedToLabel: UILabel!
    @IBOutlet weak var inProgressLabel: UILabel!
    @IBOutlet weak var inProgressDateLabel: UILabel!
    @IBOutlet weak var technicianNameLabel: UILabel!
    @IBOutlet weak var technicianPhoneNoLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        if let data = requestData {
            populateRequestDetails(data)
        }
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // Apply styling to buttons using shared function
        styleButton(callButton)
    }
    
    // MARK: - Data Population
    private func populateRequestDetails(_ request: RequestModel) {
        // Basic info
        titleLabel.text = request.title
        locationLabel.text = bulletPoint + request.location
        categoryLabel.text = request.category
        statusText.text = request.status
        descriptionLabel.text = request.description
        
        // Apply status styling using shared function
        applyStatusStyling(to: statusView, statusLabel: statusText, status: request.status)
        
        // Date formatting using shared function
        let dateFormatter = createDateFormatter()
        requestCreatedDateLabel.text = dateFormatter.string(from: request.releaseDate.dateValue())
        
        // Assigned date
        if let assignedDate = request.assignedDate {
            assignedDateLabel.text = dateFormatter.string(from: assignedDate.dateValue())
        } else {
            assignedDateLabel.text = "Not assigned yet"
        }
        
        // In-progress date
        if let inProgressDate = request.inProgressDate {
            inProgressDateLabel.text = dateFormatter.string(from: inProgressDate.dateValue())
        } else {
            inProgressDateLabel.text = "N/A"
        }
        
        // Technician info using shared function
        if !request.assignTechID.isEmpty {
            technicianNameLabel.text = "Loading..."
            technicianPhoneNoLabel.text = "Loading..."
            fetchTechnicianDetails(techID: request.assignTechID, nameLabel: technicianNameLabel, phoneLabel: technicianPhoneNoLabel)
        } else {
            technicianNameLabel.text = "Not assigned"
            technicianPhoneNoLabel.text = "N/A"
        }
    }
    
    // MARK: - IBActions
    @IBAction func callButtonTapped(_ sender: UIButton) {
        makePhoneCall(phoneLabel: technicianPhoneNoLabel)
    }
}

