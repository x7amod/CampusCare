//
//  MangerAssign.swift
//  CampusCare
//
//  Created by BP-36-201-09 on 14/12/2025.
//

import UIKit
import FirebaseFirestore

class MangerAssign: UIViewController {

    @IBOutlet weak var dropdown: UIButton!
    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var AssignButton: UIButton!
    
      
    
    // Receive the request
    var request: RequestModel? {
        return RequestStore.shared.currentRequest
    }
    
    private let usersCollection = UsersCollection.shared
    private var technicians: [UserModel] = []
    private var selectedTechnician: UserModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if request?.status == "Esclated" {
            AssignButton.setTitle( "Reassign", for: .normal)
        }

//        print("print req id before assign: ", requestId)
        setupHeader()
        usersCollection.isCurrentUserManager { [weak self] isManager in
            DispatchQueue.main.async {
                if isManager {
                    self?.fetchTechnicians()
                    self?.setupDropdown()
                    self?.setupPicker()
                } else {
                    self?.showSimpleAlert(title: "Access Denied", message: "You are not authorized to view requests.")
                }
            }
        }
    }
    
    
    private func setupPicker() {
          picker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) // Tomorrow onwards
      }
    
    @IBAction func Assign(_ sender: Any) {
        // is current user is Manager
        usersCollection.isCurrentUserManager { [weak self] isManager in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if !isManager {
                    self.showSimpleAlert(
                        title: "Access Denied",
                        message: "You are not authorized to assign requests."
                    )
                    return
                }

                // Check if the request exists
                guard let req = self.request else {
                    // print(" ERROR: Request is nil")
                    self.showSimpleAlert(
                        title: "Error",
                        message: "Request is nil"
                    )
                    return
                }
                
                // 3️⃣ Check if a technician is selected
                guard let tech = self.selectedTechnician else {
                    self.showSimpleAlert(
                        title: "Error",
                        message: "No technician selected"
                    )
                    
                    print(" ERROR: No technician selected")
                    return
                }

                //  Check if assigned date is valid
                let assignedDate = self.picker.date  // Date object
                let now = Calendar.current.startOfDay(for: Date())
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!

                //  if the selected date is valid
                if assignedDate < tomorrow {
                    self.showSimpleAlert(
                        title: "Error",
                        message: "Invalid date"
                    )
                    print("Invalid Date")
                    return
                }

                let timestamp = Timestamp(date: assignedDate)
                
                //  Assign the request
                let requestCollection = RequestCollection()
                requestCollection.assignRequest(reqID: req.id, techID: tech.id, assignedDate: timestamp) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success():
                            // Request assigned successfully
                            self.showSimpleAlert(
                                title: "alret",
                                message: "Request assigned successfully"
                            )
                            // print(" Request assigned successfully")
                            
                            // back to Manager Requests
                            if let managerRequestVC = self.storyboard?.instantiateViewController(withIdentifier: "MangerRequest") {
                                self.present(managerRequestVC, animated: true)
                            }
                            
                            // clearing the request from the store
                            RequestStore.shared.currentRequest = nil
                            
                        case .failure(let error):
                            print(" Failed to assign request: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    
    private func setupHeader() {
        if let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as? CampusCareHeader {
            headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
            view.addSubview(headerView)
            if request?.status == "Esclated" {
                
                headerView.setTitle("Request Reassign")
            }else {
                headerView.setTitle("Request Assign")

            }
        }

        let backButton = UIButton(frame: CGRect(x: 16, y: 50, width: 60, height: 30))
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.systemBackground, for: .normal)
        backButton.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        view.addSubview(backButton)
    }

    private func setupDropdown() {
        dropdown.setTitle("Select Technician", for: .normal)
        dropdown.showsMenuAsPrimaryAction = true
        dropdown.changesSelectionAsPrimaryAction = true
    }

    private func fetchTechnicians() {
        usersCollection.fetchTechnicians { [weak self] users in
            self?.technicians = users
            self?.configureDropdownMenu()
        }
    }

   
    
    private func configureDropdownMenu() {
        
        
        // Placeholder
        var actions: [UIAction] = [
            UIAction(title: "Select Technician", attributes: [.disabled]) { _ in
                
            }
        ]

        let techActions = technicians.map { tech in
            UIAction(title: tech.username) { [weak self] _ in
                self?.selectedTechnician = tech
                self?.dropdown.setTitle(tech.FirstName, for: .normal)
                print("Selected tech ID:", tech.id)
            }
        }

        actions.append(contentsOf: techActions)

        dropdown.menu = UIMenu(title: "Technicians", children: actions)
        dropdown.setTitle("Select Technician", for: .normal)
    }


    @objc func closeVC() {
        dismiss(animated: true)
    }
}
