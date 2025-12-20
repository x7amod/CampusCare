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
    var request: RequestModel?  // receive full request

    private let usersCollection = UsersCollection()
    private var technicians: [UserModel] = []
    private var selectedTechnician: UserModel?

    override func viewDidLoad() {
        super.viewDidLoad()

//        print("print req id before assign: ", requestId)
        setupHeader()
        fetchTechnicians()
        setupDropdown()
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

        let assignedDate = Timestamp(date: picker.date)
        
        let requestCollection = RequestCollection()
        requestCollection.assignRequest(reqID: req.id, techID: tech.id, assignedDate: assignedDate) { result in
            switch result {
            case .success():
                print(" Request assigned successfully")
                DispatchQueue.main.async {
                    if let managerRequestVC = self.storyboard?.instantiateViewController(withIdentifier: "MangerRequest") {
                        self.present(managerRequestVC, animated: true)
                    }
                }
            case .failure(let error):
                print(" Failed to assign request: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupHeader() {
        if let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as? CampusCareHeader {
            headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
            view.addSubview(headerView)
            headerView.setTitle("Request Assign")
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
        let actions = technicians.map { tech in
            UIAction(title: tech.username) { [weak self] _ in
                self?.selectedTechnician = tech
                self?.dropdown.setTitle(tech.username, for: .normal)
                print("Selected tech ID:", tech.id)
            }
        }

        dropdown.menu = UIMenu(title: "Technicians", children: actions)
    }

    @objc func closeVC() {
        dismiss(animated: true)
    }
}
