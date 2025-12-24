//
//  MangerDetails.swift
//  CampusCare
//
//  Created by BP-36-201-09 on 14/12/2025.
//

import UIKit
import FirebaseFirestore

class MangerDetails: UIViewController {

    var request: RequestModel? {
        return RequestStore.shared.currentRequest
    }  // receives the data
    
    //collection:
    let usersCollection = UsersCollection.shared

    // Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var img: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupHeader()
        setupBackButton()
        usersCollection.isCurrentUserManager { [weak self] isManager in
            DispatchQueue.main.async {
                if isManager {
                    self?.populateRequestDetails()
                } else {
                    self?.showSimpleAlert(title: "Access Denied", message: "You are not authorized to view requests.")
                }
            }
        }
    }
    
    //Header
    private func setupHeader() {
        if let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as? CampusCareHeader {
            headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
            view.addSubview(headerView)
            headerView.setTitle("Request Details")
        }
    }

    // back Button
    private func setupBackButton() {
        let backButton = UIButton(frame: CGRect(x: 16, y: 50, width: 60, height: 30))
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.systemBackground, for: .normal)
        backButton.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        view.addSubview(backButton)
    }

    //  Request
    private func populateRequestDetails() {
        guard let r = request else { return }

        titleLabel?.text = r.title
        idLabel?.text = r.id
        categoryLabel?.text = r.category
        roleLabel?.text = r.location
        timeLabel?.text = DateFormatter.localizedString(from: r.releaseDate.dateValue(), dateStyle: .medium, timeStyle: .none)
        priorityLabel?.text = r.priority
        updateAssignButton(for: r.status)

       

        // Image loading
        if !r.imageURL.isEmpty, let url = URL(string: r.imageURL) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async { [weak self] in
                        self?.img?.image = UIImage(data: data)
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.img?.image = UIImage(named: "defaultImage")
                    }
                }
            }
        } else {
            img?.image = UIImage(named: "defaultImage")
        }
      
        
//        print(r.id)
        
    }

    //  show Assign VC
    var shouldShowAssign = false

    @IBAction func showAssign(_ sender: Any) {
        guard let r = self.request else {
            print(" Request is nil in MangerDetails")
            return
        }

        // put the request in the singleton
        RequestStore.shared.currentRequest = r

        shouldShowAssign = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if shouldShowAssign {
            shouldShowAssign = false
            presentAssignVC()
        }
    }
    
    private func updateAssignButton(for status: String) {
        let disabledStatuses: Set<String> = [
            "Complete",
            "In-Progress",
            "Assigned"
        ]
        
        let isDisabled = disabledStatuses.contains(status)
        
        button.isEnabled = !isDisabled
        button.alpha = isDisabled ? 0.5 : 1.0
    }

    private func presentAssignVC() {
//        // Read request from the store
//        guard let request = RequestStore.shared.currentRequest else {
//            print("No request in RequestStore")
//            return
//        }

        let storyboard = UIStoryboard(name: "TechManager", bundle: nil)
        let assignVC = storyboard.instantiateViewController(withIdentifier: "MangerAssign") as! MangerAssign
        assignVC.modalPresentationStyle = .fullScreen
        self.present(assignVC, animated: true)
    }

    // close
    @objc func closeVC() {
        dismiss(animated: true)
    }


}
