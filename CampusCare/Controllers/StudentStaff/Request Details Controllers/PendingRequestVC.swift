//
//  PendingRequestVC.swift
//  CampusCare
//
//  Created by m1 on 31/12/2025.
//

import UIKit
import FirebaseFirestore


class PendingRequestVC: RequestDetailsBaseViewController {
    
    // MARK: - IBOutlets specific to PendingRequestPage
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var modifyRequestButton: UIButton!
    @IBOutlet weak var cancelRequestButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var requestCreatedDateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        if let data = requestData {
            populateRequestDetails(data)
        }
    }
    
    private func setupUI() {
        // Apply styling to buttons using shared function
        styleButton(modifyRequestButton)
        styleButton(cancelRequestButton)
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
    }
    
    // MARK: - IBActions
    @IBAction func modifyRequestButtonTapped(_ sender: UIButton) {
        guard let storyboard = self.storyboard else { return }
        
        let modifyRequestVC = storyboard.instantiateViewController(withIdentifier: "ModifyRequestsStudStaff")
        
        // Pass the request data to the modify controller
        if let modifyVC = modifyRequestVC as? ModifyRequestsStudStaff {
            modifyVC.requestData = self.requestData
        }
        
        // Present the modify request page
        self.navigationController?.pushViewController(modifyRequestVC, animated: true)
    }
    
    @IBAction func cancelRequestButtonTapped(_ sender: UIButton) {
        // TODO: Implement cancel request
        let alert = UIAlertController(
                title: "Cancel Request",
                message: "Are you sure you want to cancel this request?",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "No", style: .cancel))
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
                self?.cancelRequestInFirebase()
            })

            present(alert, animated: true)
    }
    
    
    private func cancelRequestInFirebase() {
        guard let requestId = requestData?.id else { return }

        let db = Firestore.firestore()

        db.collection("requests")
            .document(requestId)
            .updateData([
                "status": "Cancelled",
                "updatedAt": Timestamp()
            ]) { [weak self] error in

                if let error = error {
                    print("Error cancelling request:", error)
                    return
                }

                self?.showCancelSuccessPopup()
            }
    }
    
    
    private func showCancelSuccessPopup() {
        let alert = UIAlertController(
            title: "Cancelled",
            message: "Your request has been cancelled successfully.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })

        present(alert, animated: true)
    }


}
