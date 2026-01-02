//
//  TechList.swift
//  CampusCare
//
//  Created by BP-36-201-14 on 29/11/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


class TechList: UIViewController {
    
    let requestCollection = RequestCollection()
    var requests: [RequestModel] = []
    var allRequests: [RequestModel] = [] //store unfiltered , brownie
    
    //tech chat button by malak
    @IBAction func chatButtonTapped(_ sender: UIButton) {
        print("🔥 Tech Chat button tapped")
        
        let storyboard = UIStoryboard(name: "Technician", bundle: nil)
            let vc = storyboard.instantiateViewController(
                withIdentifier: "ChatsListViewController"
            )

            navigationController?.pushViewController(vc, animated: true)
    }
    
    
//end of malak work

    //variables up
   private var currentTechID: String? {
           return UserStore.shared.currentUserID
       }
    //variables down too + outlets
    //brownie
    private var selectedPriority: String? = nil
        private var selectedStatus: String? = nil
        private var selectedSortOption: String? = "priority" // Default sort
    
    
    
    @IBOutlet weak var techSearch: UISearchBar!
    
    @IBOutlet weak var techStack: UIStackView!
    
    @IBOutlet weak var filterButton: UIButton!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh data when returning from details
        fetchTechTasks()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        techStack.spacing = 15 // Adds space between cards
        techStack.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        techStack.isLayoutMarginsRelativeArrangement = true
        
        
        
        //search bar custom
        
      
        //brownie
        setupFilterMenu()
        updateFilterButtonAppearance()
        
        
        //  techSearch.delegate = self //brownie, try to rm the comment if didnt work
        fetchTechTasks()
        
        
        
        
        
        
        
    }
    private func setupHeader() {
        if let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as? CampusCareHeader {
            headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
            view.addSubview(headerView)
            headerView.setTitle("My Tasks")
        }
    }
    

    func fetchTechTasks() {
        guard let techID = currentTechID else {
            print("Error: No technician ID found")
          // showEmptyState() //pasta
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
                        self?.allRequests = list //brownie
                        self?.applyFilters()
                        //self?.reloadStackView()brownie
                    }
                case .failure(let error):
                    print("Error fetching tech tasks: \(error.localizedDescription)")
                    self?.showEmptyState() //pasta
                  //  self?.requests = []
                  //  self?.allRequests = []
                  //  self?.reloadStackView()
                }
            }
        }
    }
    
    
    
    
    private func showEmptyState() {
        //clear eexisting labels
        techStack.arrangedSubviews.forEach { $0.removeFromSuperview() }//pasta
        
        
        let label = UILabel()
        label.text = "No tasks assigned yet"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray
        label.tag = 999//pasta
        techStack.addArrangedSubview(label)
        //constraint to center //pasta
      
       
        
        
        
    }

    private func setupFilterMenu() { //filter, brownie
        // Priority filter options
        let priorityActions = ["High", "Medium", "Low"].map { priority in
            UIAction(title: priority) { [weak self] _ in
                if priority == "All" {
                    self?.selectedPriority = nil
                } else {
                    self?.selectedPriority = priority
                }
                self?.applyFilters()
            }
        }
        
        // Status filter options (only statuses tech can have)
        let statusActions = ["Assigned", "In-Progress"].map { status in
            UIAction(title: status) { [weak self] _ in
                if status == "All" {
                    self?.selectedStatus = nil
                } else {
                    self?.selectedStatus = status
                }
                self?.applyFilters()
            }
        }
        
        // Sort options
        let sortActions = ["Priority", "Due Date", "Recently Added", "Title"].map { sortOption in
            UIAction(title: sortOption) { [weak self] _ in
                self?.selectedSortOption = sortOption
                self?.applyFilters()
            }
        }
        
        // Clear all filters action
        let clearAction = UIAction(
            title: "Clear All Filters",
            attributes: .destructive
        ) { [weak self] _ in
            self?.selectedPriority = nil
            self?.selectedStatus = nil
            self?.selectedSortOption = "priority"
            self?.applyFilters()
        }
        
        // Create the menu
        filterButton.menu = UIMenu(
            title: "Filter & Sort",
            children: [
                UIMenu(title: "Filter by Priority", options: .displayInline, children: priorityActions),
                UIMenu(title: "Filter by Status", options: .displayInline, children: statusActions),
                UIMenu(title: "Sort by", options: .displayInline, children: sortActions),
                clearAction
            ]
        )
        
        filterButton.showsMenuAsPrimaryAction = true
    }
    
    
    //brownie
    private func applyFilters() {
        var filtered = allRequests
        
        // Apply priority filter
        if let selectedPriority = selectedPriority {
            filtered = filtered.filter { $0.priority == selectedPriority }
        }
        
        // Apply status filter
        if let selectedStatus = selectedStatus {
            filtered = filtered.filter { $0.status == selectedStatus }
        }
        
        // Apply sorting
        filtered = sortRequests(requests: filtered, by: selectedSortOption ?? "priority")
        
        // Update the displayed requests
        requests = filtered
        reloadStackView()
        
        // Update button appearance to show active filters
        updateFilterButtonAppearance()
    }

    private func sortRequests(requests: [RequestModel], by option: String) -> [RequestModel] {
        switch option.lowercased() {
        case "priority":
            // Order: High → Medium → Low
            let priorityOrder = ["High": 1, "Medium": 2, "Low": 3]
            return requests.sorted { priorityOrder[$0.priority] ?? 4 < priorityOrder[$1.priority] ?? 4 }
            
        case "due date":
            // Sort by deadline (closest first), then by assigned date
            return requests.sorted {
                let date1 = $0.deadline?.dateValue() ?? Date.distantFuture
                let date2 = $1.deadline?.dateValue() ?? Date.distantFuture
                return date1 < date2
            }
            
        case "recently added":
            // Sort by release date (newest first)
            return requests.sorted { $0.releaseDate.dateValue() > $1.releaseDate.dateValue() }
            
        case "title":
            // Sort alphabetically by title
            return requests.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
            
        default:
            return requests
        }
    }

    private func updateFilterButtonAppearance() {
        var hasActiveFilters = false
        
        // Check if any filters are active
        if selectedPriority != nil || selectedStatus != nil {
            hasActiveFilters = true
        }
        
        // Update button appearance
        if hasActiveFilters {
            filterButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
            filterButton.setTitleColor(.systemBlue, for: .normal)
            filterButton.layer.borderWidth = 1
            filterButton.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            filterButton.backgroundColor = .systemGray6
            filterButton.setTitleColor(.label, for: .normal)
            filterButton.layer.borderWidth = 0
        }
        
        filterButton.layer.cornerRadius = 8
        filterButton.clipsToBounds = true
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //UI Rendering Logic
    func reloadStackView() {
        // Clear previous items
        techStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        //check for any requests //pasta
        if requests.isEmpty {
            
            
            
            
            
                showEmptyState()
               return
            }
        //test pasta
        //techStack.isHidden = false
        
        
        
        
        for r in requests {
            // Instantiate the dummy card view
            let item = RequestItemView.instantiate()
            item.configure(with: r)
            
        
           
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
           // techSearch.searchBarStyle = .minimal
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
    
    
    
    
    
    
    
    
    
}






    // 7. Search Bar Implementation
    extension TechList: UISearchBarDelegate {
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            
            guard let techID = currentTechID else { return }
            
            if searchText.isEmpty {
                //at step 6, brownie
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


