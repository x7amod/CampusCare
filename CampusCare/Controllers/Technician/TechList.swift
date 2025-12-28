//
//  TechList.swift
//  CampusCare
//
//  Created by BP-36-201-14 on 29/11/2025.
//

import UIKit
import FirebaseFirestore


class TechList: UIViewController {
    
    let requestCollection = RequestCollection()
    var requests: [RequestModel] = []
   private var currentTechID: String? {
           return UserStore.shared.currentUserID
       }
    
    
    @IBOutlet weak var techSearch: UISearchBar!
    
    @IBOutlet weak var techStack: UIStackView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh data when returning from details
        fetchTechTasks()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as! CampusCareHeader
//        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
//        view.addSubview(headerView)
//        
//        // Set page-specific title
//        headerView.setTitle("My Tasks")  // Change this for each screen
        
        techStack.layoutMargins = UIEdgeInsets(top: 130, left: 16, bottom: 20, right: 16)
        techStack.isLayoutMarginsRelativeArrangement = true
        techStack.spacing = 15 // Adds space between cards
        
        //search bar custom
        
      
        
    
        
        
        //  techSearch.delegate = self
        fetchTechTasks()
        
        
        
        
        
        
        
    }
    private func setupHeader() {
        if let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as? CampusCareHeader {
            headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
            view.addSubview(headerView)
            headerView.setTitle("My Tasks")
        }
    }
    
    // 5. Fetch Logic
    //func fetchTechTasks() {
         //Currently fetching all to test, later you can filter by Tech ID
      //  requestCollection.fetchAllRequests { [weak self] result in
        //    DispatchQueue.main.async {
          //      switch result {
            //    case .success(let list):
              //      self?.requests = list
                //    self?.reloadStackView()
               // case .failure(let error):
                 //   print("Error: \(error.localizedDescription)")
                //}
            //}
        //}
    //}
 
    func fetchTechTasks() {
        guard let techID = currentTechID else {
            print("Error: No technician ID found")
            showEmptyState()
            return
        }
        
        // Use the new tech-specific method
        requestCollection.fetchRequestsForTech(techID: techID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    if list.isEmpty {
                        self?.showEmptyState()
                    } else {
                        self?.requests = list
                        self?.reloadStackView()
                    }
                case .failure(let error):
                    print("Error fetching tech tasks: \(error.localizedDescription)")
                    self?.showEmptyState()
                }
            }
        }
    }
    
    
    
    
    private func showEmptyState() {
        let label = UILabel()
        label.text = "No tasks assigned yet"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray
        techStack.addArrangedSubview(label)
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // 6. UI Rendering Logic
    func reloadStackView() {
        // Clear previous items
        techStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for r in requests {
            // Instantiate the dummy card view
            let item = RequestItemView.instantiate()
            item.configure(with: r)
            
            // Handle Taps (Navigation to details)
           // item.onTap = { [weak self] in
               // guard let self = self else { return }
                
               // print("Tech clicked on task: \(r.id ?? "Unknown ID")")
                
              //  RequestStore.shared.currentRequest = r
                  //  print("Stored request: \(r.title)")
                //pepsi
            item.onTap = { [weak self] in
                guard let self = self else { return }
                
                // Store in RequestStore (for safety/backup)
                RequestStore.shared.currentRequest = r
                print("Navigating to details for: \(r.title)")
                
                // Navigate via segue
                self.performSegue(withIdentifier: "showTechDetails", sender: r)
                
                //pepsi ssafe
                
                
            }
            
            //ui layout
            
            // Constraints for the card height inside the stack
            item.translatesAutoresizingMaskIntoConstraints = false
            item.heightAnchor.constraint(equalToConstant: 140).isActive = true
            techStack.addArrangedSubview(item)
            techSearch.searchBarStyle = .minimal
        }
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTechDetails" {
            if let destinationVC = segue.destination as? TechDetails,
               let selectedRequest = sender as? RequestModel {
                // Pass the data directly
                destinationVC.request = selectedRequest
            }
        }
    }
    
    //pepsi important - error click on task 
    
    
    
    
    
    
    
}






    // 7. Search Bar Implementation
    extension TechList: UISearchBarDelegate {
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            
            guard let techID = currentTechID else { return }
            
            if searchText.isEmpty {
                fetchTechTasks()
                return
            }
            
            
            requestCollection.fetchRequestsForTech(techID: techID) { [weak self] result in
                    DispatchQueue.main.async {
                        if case .success(let list) = result {
                            // Filter locally by title
                            let filtered = list.filter { request in
                                request.title.lowercased().contains(searchText.lowercased())
                            }
                            self?.requests = filtered
                            self?.reloadStackView()
                        }
                    }
            
            
            
            
            
            
            
           // requestCollection.searchRequests(prefix: searchText) { [weak self] result in
               // DispatchQueue.main.async {
                //    if case .success(let list) = result {
                     //   self?.requests = list
                    //    self?.reloadStackView()
                  //  }
               // }
           }//comment this is rollback
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


