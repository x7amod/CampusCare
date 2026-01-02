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
    @IBOutlet weak var requestImageButton: UIButton!
    
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
        
        loadImageOnButton(from: request.imageURL)
    }
    
    
    private func loadImageOnButton(from urlString: String?) {
        guard
            let urlString = urlString,
            !urlString.isEmpty,
            let url = URL(string: urlString)
        else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                self.requestImageButton.setImage(image, for: .normal)
                self.requestImageButton.setTitle("", for: .normal)
                self.requestImageButton.imageView?.contentMode = .scaleAspectFill
                self.requestImageButton.clipsToBounds = true
            }
        }.resume()
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
        
        let alert = UIAlertController(
            title: "Cancel Request",
            message: "Are you sure you want to cancel this request?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.deleteRequestFromFirebase()
        })
        
        present(alert, animated: true)
    }
    
    
    
    private func deleteRequestFromFirebase() {
        guard let request = requestData else { return }

        Firestore.firestore()
            .collection("Requests")
            .document(request.id)
            .delete { error in

                if let error = error {
                    print("❌ Failed to delete request:", error.localizedDescription)
                    return
                }

                self.showDeletedPopup()
            }
    }

    
    
    private func showDeletedPopup() {
        let alert = UIAlertController(
            title: "Request Cancelled",
            message: "Your request has been cancelled successfully.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            // Go back to previous screen (e.g. My Requests)
            self.navigationController?.popViewController(animated: true)
        })

        present(alert, animated: true)
    }



}
