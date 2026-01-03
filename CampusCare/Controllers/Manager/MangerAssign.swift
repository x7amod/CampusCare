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
    private let requestCollection = RequestCollection()
    private var technicians: [UserModel] = []
    private var selectedTechnician: UserModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Assign Task"
        
        if request?.status == "Escalated" {
            self.title = "Reassign Task"
            AssignButton.setTitle( "Reassign", for: .normal)
        }

//        print("print req id before assign: ", requestId)
        //setupHeader()
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

        let deadline = picker.date  // Date object
                let now = Calendar.current.startOfDay(for: Date())
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!

                //  if the selected date is valid
                if deadline < tomorrow {
                    print("Invalid Date")
                    return
                }

                let timestamp = Timestamp(date: deadline)
                let assignedDate = Timestamp(date: Date())
        
        
        requestCollection.assignRequest(reqID: req.id, techID: tech.id, assignedDate: assignedDate, deadline: timestamp) { result in
            switch result {
            case .success():
                print(" Request assigned successfully")
                DispatchQueue.main.async {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
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
            if request?.status == "Escalated" {
                
                headerView.setTitle("Request Reassign")
            }else {
                headerView.setTitle("Request Assign")

            }
        }

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
        
    
        let oldTechID = request?.assignTechID
        
        // out the old tech
        let availableTechnicians = technicians.filter { tech in
            if request?.status == "Escalated" {
                return tech.id != oldTechID
            }
            return true
        }

        // Placeholder
        var actions: [UIAction] = [
            UIAction(title: "Select Technician", attributes: [.disabled]) { _ in }
        ]

        let techActions = availableTechnicians.map { tech in
            UIAction(title: tech.FirstName) { [weak self] _ in
                self?.selectedTechnician = tech
                self?.dropdown.setTitle(tech.FirstName, for: .normal)
                print("Selected tech ID:", tech.id)
            }
        }

        actions.append(contentsOf: techActions)

        dropdown.menu = UIMenu(title: "Technicians", children: actions)
        dropdown.setTitle("Select Technician", for: .normal)
    }


}
