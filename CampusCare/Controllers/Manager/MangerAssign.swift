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
    
    private let usersCollection = UsersCollection()
    private var technicians: [UserModel] = []
    private var selectedTechnician: UserModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if request?.status == "Esclated" {
            AssignButton.setTitle( "Reassign", for: .normal)
        }

//        print("print req id before assign: ", requestId)
        setupHeader()
        fetchTechnicians()
        setupDropdown()
        setupPicker()
    }
    
    
    private func setupPicker() {
          picker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) // Tomorrow onwards
      }
    @IBAction func Assign(_ sender: Any) {
        guard let req = self.request else {
            print(" ERROR: Request is nil")
            return
        }
        
        guard let tech = selectedTechnician else {
            print(" ERROR: No technician selected")
            return
        }

        let assignedDate = picker.date  // Date object
                let now = Calendar.current.startOfDay(for: Date())
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!

                //  if the selected date is valid
                if assignedDate < tomorrow {
                    print("Invalid Date")
                    return
                }

                let timestamp = Timestamp(date: assignedDate)
        
        
        let requestCollection = RequestCollection()
        requestCollection.assignRequest(reqID: req.id, techID: tech.id, assignedDate: timestamp) { result in
            switch result {
            case .success():
                print(" Request assigned successfully")
                DispatchQueue.main.async {
                    if let managerRequestVC = self.storyboard?.instantiateViewController(withIdentifier: "MangerRequest") {
                        self.present(managerRequestVC, animated: true)
                    }
                }
                // clearing the request from the store
                RequestStore.shared.currentRequest = nil
            case .failure(let error):
                print(" Failed to assign request: \(error.localizedDescription)")
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
