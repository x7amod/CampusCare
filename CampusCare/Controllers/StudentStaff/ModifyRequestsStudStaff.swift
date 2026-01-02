//
//  ModifyRequestsStudStaff.swift
//  CampusCare
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class ModifyRequestsStudStaff: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var priorityButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var uploadingPhotoButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    
    
    // MARK: - Properties
    
    var requestData: RequestModel?
    private var hasChanges = false
    private var selectedImage: UIImage?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDropdownButton(categoryButton)
        setupDropdownButton(priorityButton)
        setupCategoryMenu()
        setupPriorityMenu()

        setupUI()
        populateFields()
        setupChangeDetection()
        setupBackButton()
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addDashedBorder()
    }

    // MARK: - UI Setup
    private func setupUI() {
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.systemGray5.cgColor
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.clipsToBounds = true
    }

    // MARK: - Dashed Border
    private func addDashedBorder() {
        uploadingPhotoButton.layer.sublayers?
            .filter { $0.name == "DashedBorder" }
            .forEach { $0.removeFromSuperlayer() }

        let dashedLayer = CAShapeLayer()
        dashedLayer.name = "DashedBorder"
        dashedLayer.strokeColor = UIColor.systemGray.cgColor
        dashedLayer.lineDashPattern = [6, 4]
        dashedLayer.fillColor = UIColor.clear.cgColor
        dashedLayer.frame = uploadingPhotoButton.bounds
        dashedLayer.path = UIBezierPath(
            roundedRect: uploadingPhotoButton.bounds,
            cornerRadius: 8
        ).cgPath

        uploadingPhotoButton.layer.addSublayer(dashedLayer)
    }

    // MARK: - Dropdown Setup
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
    
    
    private func setupCategoryMenu() {

        let categories = [
            "Electrical",
            "AC",
            "Plumbing",
            "Network / Wifi",
            "IT Equipment",
            "Safety & Equipment",
            "Building / Structural",
            "Other"
        ]

        let actions = categories.map { category in
            UIAction(title: category) { _ in
                self.updateDropdownTitle(self.categoryButton, title: category)
                self.hasChanges = true
            }
        }

        categoryButton.menu = UIMenu(
            title: "",
            options: .displayInline,
            children: actions
        )

        categoryButton.showsMenuAsPrimaryAction = true
    }

    
    private func setupPriorityMenu() {

        let priorities = [
            "Low",
            "Medium",
            "High"
        ]

        let actions = priorities.map { priority in
            UIAction(title: priority) { _ in
                self.updateDropdownTitle(self.priorityButton, title: priority)
                self.hasChanges = true
            }
        }

        priorityButton.menu = UIMenu(
            title: "",
            options: .displayInline,
            children: actions
        )

        priorityButton.showsMenuAsPrimaryAction = true
    }


    // MARK: - Populate Data
    private func populateFields() {
        guard let request = requestData else { return }

        titleTextField.text = request.title
        locationTextField.text = request.location
        updateDropdownTitle(categoryButton, title: request.category)
        updateDropdownTitle(priorityButton, title: request.priority)
        descriptionTextView.text = request.description
        
        loadImageOnButton(from: request.imageURL)
    }

    // MARK: - Change Detection
    private func setupChangeDetection() {
        [titleTextField, locationTextField].forEach {
            $0?.addTarget(self, action: #selector(fieldChanged), for: .editingChanged)
        }
        descriptionTextView.delegate = self
    }

    @objc private func fieldChanged() {
        hasChanges = true
    }

    // MARK: - Back Button
    private func setupBackButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
    }

    @objc private func backTapped() {
        if hasChanges {
            showUnsavedChangesAlert()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    private func showUnsavedChangesAlert() {
        let alert = UIAlertController(
            title: "Unsaved Changes",
            message: "Are you sure you want to leave without saving?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Stay", style: .cancel))
        alert.addAction(UIAlertAction(title: "Leave", style: .destructive) { _ in
            self.navigationController?.popViewController(animated: true)
        })

        present(alert, animated: true)
    }

    // MARK: - Image Upload (NO UIImageView)
    @IBAction func uploadPhotoTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    // MARK: - Update Request
    @IBAction func updateButtonTapped(_ sender: UIButton) {
      
        if let image = selectedImage {
            uploadImageThenUpdate(image)
        } else {
            updateRequestInFirebase(imageURL: requestData?.imageURL)
        }
    }

    // MARK: - Firebase Image Upload
    private func uploadImageThenUpdate(_ image: UIImage) {
        guard let request = requestData,
              let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let ref = Storage.storage()
            .reference()
            .child("request_images/\(UUID().uuidString).jpg") // 🔥 IMPORTANT

        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Upload failed:", error.localizedDescription)
                return
            }

            ref.downloadURL { url, _ in
                guard let imageURL = url?.absoluteString else { return }

                // ✅ FORCE UI UPDATE IMMEDIATELY
                DispatchQueue.main.async {
                    self.uploadingPhotoButton.setImage(image, for: .normal)
                    self.uploadingPhotoButton.setTitle("", for: .normal)
                    self.uploadingPhotoButton.imageView?.contentMode = .scaleAspectFill
                    self.uploadingPhotoButton.clipsToBounds = true
                }

                // ✅ Update Firestore + local model
                self.updateRequestInFirebase(imageURL: imageURL)
            }
        }
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
                self.uploadingPhotoButton.setImage(image, for: .normal)
                self.uploadingPhotoButton.setTitle("", for: .normal)
                self.uploadingPhotoButton.imageView?.contentMode = .scaleAspectFill
                self.uploadingPhotoButton.clipsToBounds = true
            }
        }.resume()
    }


    // MARK: - Firestore Update
    private func updateRequestInFirebase(imageURL: String?) {
        guard let request = requestData else { return }

        
       
        
        let updatedData: [String: Any] = [
            "title": titleTextField.text ?? "",
            "location": locationTextField.text ?? "",
            "category": categoryButton.configuration?.title ?? "",
            "priority": priorityButton.configuration?.title ?? "",
            "description": descriptionTextView.text ?? "",
            "imageURL": imageURL ?? "",
            "updatedAt": Timestamp()
        ]
        
        Firestore.firestore()
            .collection("Requests")
            .document(request.id)
            .updateData(updatedData) { [weak self] error in

                if let error = error {
                    print("Update failed:", error.localizedDescription)
                    return
                }
                if let imageURL = imageURL {
                    self?.requestData?.imageURL = imageURL
                }



                self?.hasChanges = false
                self?.showSuccessPopup()
            }
        

    }

    
    
    
    private func showSuccessPopup() {
        let alert = UIAlertController(
            title: "Updated",
            message: "Request has been updated successfully.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })

        present(alert, animated: true)
    }
}

// MARK: - Delegates
extension ModifyRequestsStudStaff: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        hasChanges = true
    }
}

extension ModifyRequestsStudStaff: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        if let image = info[.originalImage] as? UIImage {

            // ✅ Store selected image
            selectedImage = image

            // ✅ IMMEDIATELY update the UI
            uploadingPhotoButton.setImage(image, for: .normal)
            uploadingPhotoButton.setTitle("", for: .normal)
            uploadingPhotoButton.imageView?.contentMode = .scaleAspectFill
            uploadingPhotoButton.clipsToBounds = true

            hasChanges = true
        }

        dismiss(animated: true)
    }

}
