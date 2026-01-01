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
    
    var selectedCategory: String?
    var selectedPriority: String?
    var selectedImage: UIImage?
    var uploadedImageURL: String?
    let db = Firestore.firestore()
    
    
    
    @IBAction func categoryTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Select Category",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let categories = ["Electrical", "Plumbing", "AC", "Network/WIFI" , "IT Equipment", "Safety & Equipment", "Building/Structural", "Other"]
        
        for category in categories {
            alert.addAction(UIAlertAction(title: category, style: .default) { _ in
                self.selectedCategory = category
                sender.setTitle(category, for: .normal)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    
    
    @IBOutlet weak var priorityButton: UIButton!
    
    @IBAction func priorityTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Select Priority",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let priorities = ["Low", "Medium", "High"]
        
        for priority in priorities {
            alert.addAction(UIAlertAction(title: priority, style: .default) { _ in
                self.selectedPriority = priority
                sender.setTitle(priority, for: .normal)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
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
        
        guard
            !title.isEmpty,
            !location.isEmpty,
            let category = selectedCategory,
            let priority = selectedPriority,
            !description.isEmpty,
            let uid = Auth.auth().currentUser?.uid
        else {
            showSimpleAlert(title: "Error", message: "Please fill all fields")
            return
        }
        
        
        // Prevent multiple taps
        (sender as? UIButton)?.isEnabled = false
        
        let ticketId = "REQ-\(Int.random(in: 1000...9999))"
        
        func saveRequest(imageURL: String) {
            let data: [String: Any] = [
                
                "title": title,
                "location": location,
                "category": category,
                "priority": priority,
                "description": description,
                "status": "Pending",
                "creatorID": uid,
                "creatorRole": "",
                "imageURL": imageURL,
                "releaseDate": Timestamp(),
                "completedDate": NSNull(),
                "deadline": NSNull(),
                "assignedDate": NSNull(),
                "assignTechID": "",
                "inProgressDate": NSNull(),
                "lastUpdateDate": NSNull()
            ]
            
            Firestore.firestore()
                .collection("Requests")
                .addDocument(data: data) { error in
                    
                    (sender as? UIButton)?.isEnabled = true
                    
                    if let error = error {
                        self.showSimpleAlert(title: "Error", message: error.localizedDescription)
                        return
                    }
                    self.showSuccessAlertAndGoHome(ticketId: ticketId)
                }
            
            Firestore.firestore()
              .collection("Users")
              .document(uid)
              .getDocument { snapshot, _ in

                  let role = snapshot?.data()?["role"] as? String ?? "student"

                  saveRequest(creatorRole: role)
            }
            func saveRequest(creatorRole: String) {
                let data: [String: Any] = [
                    "creatorID": uid,
                    "creatorRole": creatorRole,
                ]
            }


        }
        // Upload image if exists
           if let image = selectedImage {
               CloudinaryManager.shared.uploadImage(image: image) { imageURL in
                   saveRequest(imageURL: imageURL ?? "")
               }
           } else {
               saveRequest(imageURL: "")
           }
       }
        
    func showSuccessAlertAndGoHome(ticketId: String) {
        let alert = UIAlertController(
            title: "Success",
            message: "Request submitted successfully.\nTicket ID: \(ticketId)",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.tabBarController?.selectedIndex = 0
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
    
    
    
    
    
    
    
    
    
    
    
    
  
    
    

