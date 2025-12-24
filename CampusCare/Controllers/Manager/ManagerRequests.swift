//
//  TechRequests.swift
//  CampusCare
//
//  Created by BP-36-201-14 on 29/11/2025.
//

import UIKit
import FirebaseFirestore

class ManagerRequests: UIViewController {

    //collection
    let requestCollection = RequestCollection()
    let usersCollection = UsersCollection.shared
    
    //arrays and var
    var allRequests: [RequestModel] = []   // original data
    var requests: [RequestModel] = []      // filtered data
    var selectedPriority: String? = nil
    var selectedStatus: String? = nil
    
    
    @IBOutlet weak var stackVIew: UIStackView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterDrop: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeader()
        // search Bar
        searchBar.delegate = self
        UsersCollection.shared.isCurrentUserManager { [weak self] isManager in
               DispatchQueue.main.async {
                   if isManager {
                       self?.FetchRequests()
                       self?.setupFilterMenu()
                   } else {
                       self?.showSimpleAlert(title: "Access Denied", message: "You are not authorized to view requests.")
                   }
               }
           }
   

    }
    
    func setupHeader() {
        // Do any additional setup after loading the view.
        let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as! CampusCareHeader
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        view.addSubview(headerView)
        
        // Set page-specific title
        headerView.setTitle("Requests Pool") // Change this for each screen

        // StackView top padding
        stackVIew.layoutMargins = UIEdgeInsets(top: 130, left: 0, bottom: 0, right: 0)
        stackVIew.isLayoutMarginsRelativeArrangement = true
        
    }
    
    func setupFilterMenu() {
        
        let priorityActions = ["High", "Medium", "Low"].map { priority in
            UIAction(title: priority) { [weak self] _ in
                self?.selectedPriority = priority
                self?.applyFilters()
            }
        }
        
        let statusActions = ["Assigned", "Complete", "Pending", "Escalated", "In-Progress"].map { status in
            UIAction(title: status) { [weak self] _ in
                self?.selectedStatus = status
                self?.applyFilters()
            }
        }
        
        let clearAction = UIAction(
            title: "Clear Filters",
            attributes: .destructive
        ) { [weak self] _ in
            self?.selectedPriority = nil
            self?.selectedStatus = nil
            self?.applyFilters()
        }
        
        filterDrop.menu = UIMenu(
            title: "Filter Requests",
            children: [
                UIMenu(title: "Priority", options: .displayInline, children: priorityActions),
                UIMenu(title: "Status", options: .displayInline, children: statusActions),
                clearAction
            ]
        )
        
        filterDrop.showsMenuAsPrimaryAction = true
    }

    
    func applyFilters() {
        requests = allRequests.filter { request in
            
            let priorityMatch =
                selectedPriority == nil || request.priority == selectedPriority
            
            let statusMatch =
                selectedStatus == nil || request.status == selectedStatus
            
            return priorityMatch && statusMatch
        }
        
        reloadStackView()
    }
    
    //  fetch All
    func FetchRequests() {
        requestCollection.fetchAllRequests { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self?.allRequests = list
                    self?.applyFilters()
                case .failure(let error):
                    print("Error fetching requests: \(error.localizedDescription)")
                }
            }
        }
    }

    // ui reload
    func reloadStackView() {
        stackVIew.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for r in requests {
            let item = RequestItemView.instantiate()
            item.configure(with: r)
            
            // Add tap to open details screen
            item.onTap = { [weak self] in
                guard let self = self else { return }

                let storyboard = UIStoryboard(name: "TechManager", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "MangerDetails") as! MangerDetails
             

                // Pass the request to the detail vc
                RequestStore.shared.currentRequest = r

                if let nav = self.navigationController {
                    nav.pushViewController(vc, animated: true)
                } else {
                    // fallback to modal if no navigation controller
                    DispatchQueue.main.async {
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }
                }
            }

            item.translatesAutoresizingMaskIntoConstraints = false
            item.heightAnchor.constraint(equalToConstant: 140).isActive = true
            stackVIew.addArrangedSubview(item)
        }
    }
}



// search Bar Delegate
extension ManagerRequests: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        requestCollection.searchRequests(prefix: searchText) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self?.requests = list
                    self?.reloadStackView()
                    
                case .failure(let error):
                    print("Search error: \(error.localizedDescription)")
                }
            }
        }
    }
}
