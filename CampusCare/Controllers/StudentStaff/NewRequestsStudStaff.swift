//
//  NewRequestsStudStaff.swift
//  CampusCare
//
//  Created by rentamac on 12/14/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Cloudinary

class NewRequestsStudStaff: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDropdownButton(categoryButton)
        setupDropdownButton(priorityButton)
        setupCategoryMenu()
        setupPriorityMenu()
        
        
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.systemGray5.cgColor
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.clipsToBounds = true
        
        
        func setupDropdownButton(_ button: UIButton) {
            var config = UIButton.Configuration.plain()

            config.title = " "
            config.image = UIImage(systemName: "chevron.down")
            config.imagePlacement = .trailing
            config.imagePadding = 8
            config.titleAlignment = .leading   // 👈 FIX
            config.baseForegroundColor = .lightGray

            config.contentInsets = NSDirectionalEdgeInsets(
                top: 12,
                leading: 16,
                bottom: 12,
                trailing: 16
            )

            button.configuration = config
            button.contentHorizontalAlignment = .fill
            button.layer.cornerRadius = 8
            button.backgroundColor = .systemGray6
        }
        func updateDropdownTitle(_ button: UIButton, title: String) {
            button.configuration?.title = title
            button.configuration?.baseForegroundColor = .label
        }

        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addDashedBorder()
    }
    
   
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var categoryButton: UIButton!
    private func setupCategoryMenu() {

        let categories = [
            "Electrical",
            "Plumbing",
            "AC",
            "Network / Wifi",
            "IT Equipment",
            "Safety & Equipment",
            "Building / Structural",
            "Other"
        ]

        let actions = categories.map { category in
            UIAction(title: category) { _ in
                self.updateDropdownTitle(self.categoryButton, title: category)
            }
        }

        categoryButton.menu = UIMenu(
            title: "",
            options: .displayInline,
            children: actions
        )

        categoryButton.showsMenuAsPrimaryAction = true
    }

    
    
    var selectedImage: UIImage?
    var uploadedImageURL: String?
    let db = Firestore.firestore()
    
    
    
  
    private func setupDropdownButton(_ button: UIButton) {
        var config = UIButton.Configuration.plain()
        config.title = "Select"
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.titleAlignment = .leading
        config.baseForegroundColor = .lightGray

        config.contentInsets = NSDirectionalEdgeInsets(
            top: 12, leading: 16, bottom: 12, trailing: 16
        )

        button.configuration = config
        button.contentHorizontalAlignment = .fill
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemGray6
    }

    private func updateDropdownTitle(_ button: UIButton, title: String) {
        button.configuration?.title = title
        button.configuration?.baseForegroundColor = .label
    }

    
    
    @IBOutlet weak var priorityButton: UIButton!
    private func setupPriorityMenu() {

        let priorities = ["Low", "Medium", "High"]

        let actions = priorities.map { priority in
            UIAction(title: priority) { _ in
                self.updateDropdownTitle(self.priorityButton, title: priority)
            }
        }

        priorityButton.menu = UIMenu(
            title: "",
            options: .displayInline,
            children: actions
        )

        priorityButton.showsMenuAsPrimaryAction = true
    }

  
    
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var uplodingPhotoButton: UIButton!
    func addDashedBorder() {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.systemGray.cgColor
        layer.lineDashPattern = [6, 4]
        layer.fillColor = UIColor.clear.cgColor
        layer.frame = uplodingPhotoButton.bounds
        layer.path = UIBezierPath(roundedRect: uplodingPhotoButton.bounds, cornerRadius: 8).cgPath
        uplodingPhotoButton.layer.addSublayer(layer)
    }
    
    
    @IBAction func uplodingPhotoTapped(_ sender: UIButton) {
        openImagePicker()
    }
    
    func openImagePicker() {
        let alert = UIAlertController(
            title: "Select Photo",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                self.openPicker(sourceType: .camera)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.openPicker(sourceType: .photoLibrary)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func openPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    
    
    
    
    @IBAction func submitButtonTapped(_ sender: Any) {

            let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let location = locationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let description = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)

            let category = categoryButton.configuration?.title ?? ""
            let priority = priorityButton.configuration?.title ?? ""

            guard
                !title.isEmpty,
                !location.isEmpty,
                !description.isEmpty,
                category != "Select",
                priority != "Select",
                let uid = Auth.auth().currentUser?.uid
            else {
                showSimpleAlert(title: "Error", message: "Please fill all fields")
                return
            }

            (sender as? UIButton)?.isEnabled = false

            let docRef = Firestore.firestore()
                .collection("Requests")
                .document()

            let requestID = docRef.documentID

            func saveRequest(imageURL: String) {

                let data: [String: Any] = [
                                "title": title,
                                "location": location,
                                "category": category,
                                "priority": priority,
                                "description": description,
                                "status": "Pending",
                                "creatorID": uid,
                                "creatorRole": "student",
                                "imageURL": imageURL,
                                "releaseDate": Timestamp(),
                                "completedDate": NSNull(),
                                "deadline": NSNull(),
                                "assignedDate": NSNull(),
                                "assignTechID": "",
                                "inProgressDate": NSNull(),
                                "lastUpdateDate": NSNull()
                ]

                docRef.setData(data) { error in
                    (sender as? UIButton)?.isEnabled = true

                    if let error = error {
                        self.showSimpleAlert(title: "Error", message: error.localizedDescription)
                        return
                    }
                    self.notifyManagerOfNewRequest(requestID: requestID, requestTitle: title)
                    self.showSuccessAlertAndGoHome(ticketId: requestID)
                }
            }

            if let image = selectedImage {
                CloudinaryManager.shared.uploadImage(image: image) { imageURL in
                    saveRequest(imageURL: imageURL ?? "")
                }
            } else {
                saveRequest(imageURL: "")
            }
        }
    
    /// Notify manager when a new request is created
    private func notifyManagerOfNewRequest(requestID: String, requestTitle: String) {
        let usersCollection = UsersCollection.shared
        let notificationsCollection = NotificationsCollection()
        
        usersCollection.fetchManagerUserID { managerID in
            guard let managerID = managerID else {
                print("[NewRequestsStudStaff] Could not find manager to notify")
                return
            }
            
            notificationsCollection.createNotification(
                userID: managerID,
                title: "New Request Awaits Assignment",
                body: "\(requestTitle) has been submitted and needs a technician.",
                type: "New",
                requestID: requestID
            ) { result in
                if case .failure(let error) = result {
                    print("[NewRequestsStudStaff] Failed to notify manager: \(error.localizedDescription)")
                } else {
                    print("[NewRequestsStudStaff] Manager notified of new request")
                }
            }
        }
    }
        
    func showSuccessAlertAndGoHome(ticketId: String) {
        let alert = UIAlertController(
            title: "Success",
            message: "Request submitted successfully.\nTicket ID: \(ticketId)",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        })

        present(alert, animated: true)
    }


        
    }
    
    
    
    
    
    
    extension NewRequestsStudStaff: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            picker.dismiss(animated: true)
            
            if let image = info[.editedImage] as? UIImage {
                selectedImage = image   // IMPORTANT for Cloudinary upload
                uplodingPhotoButton.setImage(image, for: .normal)
                uplodingPhotoButton.imageView?.contentMode = .scaleAspectFill
                uplodingPhotoButton.clipsToBounds = true
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
  
    
    

