//
//  MyRequestsViewController.swift
//  CampusCare
//
//  Created by m1 on 17/12/2025.
//
import UIKit
import FirebaseCore
import FirebaseFirestore
import Foundation

class MyRequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var TableView: UITableView!

    // refresh control for pull to refresh
    private lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        return rc
    }()

    // Configurable collection name.
    static let collectionName = "Requests"

    struct RequestModel {
        let title: String
        let id: String
        let category: String
        let date: Date
        let status: String
    }
    
    // Visible (filtered) requests
    var requests: [RequestModel] = []
    // All fetched requests (unfiltered)
    private var allRequests: [RequestModel] = []

    // Prevent overlapping fetches
    private var isLoading: Bool = false

    // Filter and sort state
    private var selectedStatus: String? = nil
    private var selectedCategory: String? = nil
    private var sortBy: SortOption = .timeSubmitted
    private var sortOrder: SortOrder = .descending
    
    enum SortOption {
        case timeSubmitted
        case lastUpdate
    }
    
    enum SortOrder {
        case ascending
        case descending
    }

    // Make Firestore lazily-initialized to ensure FirebaseApp.configure() has run.
    lazy var db: Firestore = {
        return Firestore.firestore()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // custom header
        let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as! CampusCareHeader
        let headerHeight: CGFloat = 80
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: headerHeight)
        view.addSubview(headerView)
        
        // Set page title
        headerView.setTitle("My Requests")
        
        // Adjust table view frame to start below the custom header
//        TableView.frame = CGRect(x: 0, y: headerHeight, width: view.frame.width, height: view.frame.height - headerHeight)
        
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        
        TableView.dataSource = self
        TableView.delegate = self
        TableView.separatorStyle = .none
        //TableView.tableHeaderView = searchBar
        // Hide scroll indicators | they keep appearing for some reason
        TableView.showsVerticalScrollIndicator = false
        TableView.showsHorizontalScrollIndicator = false
        // dismiss keyboard when dragging
        TableView.keyboardDismissMode = .onDrag
        // Attach refresh control to the table view
        TableView.refreshControl = refreshControl
        
        // Register Cell
        TableView.register(UINib(nibName: "StudStaffRequestCard", bundle: nil), forCellReuseIdentifier: "RequestCell")

        // Setup filter button menu
        setupFilterMenu()
        filterButton.tintColor = .black
        fetchRequestsFromFirebase()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilter(searchText: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        applyFilter(searchText: "")
        searchBar.resignFirstResponder()
    }

    // Setup filter button menu
    private func setupFilterMenu() {
        // Status filter actions
        let statusActions = [
            UIAction(title: "All Statuses", state: selectedStatus == nil ? .on : .off) { [weak self] _ in
                self?.selectedStatus = nil
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            },
            UIAction(title: "Pending", state: selectedStatus == "Pending" ? .on : .off) { [weak self] _ in
                self?.selectedStatus = "Pending"
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            },
            UIAction(title: "Assigned", state: selectedStatus == "Assigned" ? .on : .off) { [weak self] _ in
                self?.selectedStatus = "Assigned"
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            },
            UIAction(title: "In-Progress", state: selectedStatus == "In-Progress" ? .on : .off) { [weak self] _ in
                self?.selectedStatus = "In-Progress"
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            },
            UIAction(title: "Complete", state: selectedStatus == "Complete" ? .on : .off) { [weak self] _ in
                self?.selectedStatus = "Complete"
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            },
            UIAction(title: "Escalated", state: selectedStatus == "Escalated" ? .on : .off) { [weak self] _ in
                self?.selectedStatus = "Escalated"
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            }
        ]
        let statusMenu = UIMenu(title: "Filter by Status", options: [], children: statusActions)
        
        // Category filter actions
        let categoryActions = [
            UIAction(title: "All Categories", state: selectedCategory == nil ? .on : .off) { [weak self] _ in
                self?.selectedCategory = nil
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            },
            UIAction(title: "AC", state: selectedCategory == "AC" ? .on : .off) { [weak self] _ in
                self?.selectedCategory = "AC"
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            },
            UIAction(title: "Electrical", state: selectedCategory == "Electrical" ? .on : .off) { [weak self] _ in
                self?.selectedCategory = "Electrical"
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            },
            UIAction(title: "Network", state: selectedCategory == "Network" ? .on : .off) { [weak self] _ in
                self?.selectedCategory = "Network"
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            },
            UIAction(title: "IT", state: selectedCategory == "IT" ? .on : .off) { [weak self] _ in
                self?.selectedCategory = "IT"
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            },
            UIAction(title: "Building/Structural", state: selectedCategory == "Building/Structural" ? .on : .off) { [weak self] _ in
                self?.selectedCategory = "Building/Structural"
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            },
            UIAction(title: "Plumbing", state: selectedCategory == "Plumbing" ? .on : .off) { [weak self] _ in
                self?.selectedCategory = "Plumbing"
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            },
            UIAction(title: "Safety/Equipment", state: selectedCategory == "Safety/Equipment" ? .on : .off) { [weak self] _ in
                self?.selectedCategory = "Safety/Equipment"
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            }
        ]
        let categoryMenu = UIMenu(title: "Filter by Category", options: [], children: categoryActions)
        
        // Sort options
        let sortByActions = [
            UIAction(title: "Time Submitted", state: sortBy == .timeSubmitted ? .on : .off) { [weak self] _ in
                self?.sortBy = .timeSubmitted
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            },
            UIAction(title: "Last Update", state: sortBy == .lastUpdate ? .on : .off) { [weak self] _ in
                self?.sortBy = .lastUpdate
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            }
        ]
        let sortByMenu = UIMenu(title: "Sort By", options: [], children: sortByActions)
        
        // Sort order
        let sortOrderActions = [
            UIAction(title: "Ascending", state: sortOrder == .ascending ? .on : .off) { [weak self] _ in
                self?.sortOrder = .ascending
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            },
            UIAction(title: "Descending", state: sortOrder == .descending ? .on : .off) { [weak self] _ in
                self?.sortOrder = .descending
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            }
        ]
        let sortOrderMenu = UIMenu(title: "Sort Order", options: [], children: sortOrderActions)
        
        // Combine into main menu
        let mainMenu = UIMenu(title: "", children: [statusMenu, categoryMenu, sortByMenu, sortOrderMenu])
        
        filterButton.menu = mainMenu
        filterButton.showsMenuAsPrimaryAction = true
    }

    // Pull-to-refresh handler
    @objc private func handleRefresh(_ sender: UIRefreshControl) {
        // Re-query the DB to update the requests list
        fetchRequestsFromFirebase(isRefresh: true)
    }

    // Apply filter locally against loaded documents
    private func applyFilter(searchText: String?) {
        // Delegate to the full filter + sort logic
        applyFiltersAndSort()
    }
    
    // Apply all filters (search, status, category) and sorting
    private func applyFiltersAndSort() {
        var filtered = allRequests
        
        // Apply search text filter
        let text = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty {
            let lower = text.lowercased()
            filtered = filtered.filter { r in
                r.title.lowercased().contains(lower) ||
                r.category.lowercased().contains(lower) ||
                r.status.lowercased().contains(lower) ||
                r.id.lowercased().contains(lower)
            }
        }
        
        // Apply status filter
        if let status = selectedStatus {
            filtered = filtered.filter { $0.status == status }
        }
        
        // Apply category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Apply sorting
        filtered.sort { (a, b) -> Bool in
            let dateA: Date
            let dateB: Date
            
            switch sortBy {
            case .timeSubmitted:
                // Use the date field (releaseDate)
                dateA = a.date
                dateB = b.date
            case .lastUpdate:
                // For now use the same date field, TODO: need to add the lastUpdate field to the db later
                dateA = a.date
                dateB = b.date
            }
            
            return sortOrder == .ascending ? dateA < dateB : dateA > dateB
        }
        
        self.requests = filtered
        DispatchQueue.main.async {
            self.TableView.reloadData()
        }
    }

    // Fetch from Firebase
    // isRefresh parameter so we can end the refresh control when done
    func fetchRequestsFromFirebase(isRefresh: Bool = false) {
        // Avoid overlapping queries
        if isLoading {
            return
        }
        isLoading = true

        db.collection(Self.collectionName).order(by: "releaseDate", descending: true).getDocuments { (querySnapshot, error) in
            // Ensure isLoading is cleared and refresh control stopped when appropriate
            defer {
                self.isLoading = false
                if isRefresh {
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                    }
                }
            }

            if let error = error {
                print("[MyRequests] fetchRequestsFromFirebase error: \(error.localizedDescription)")
                return
            }

            guard let querySnapshot = querySnapshot else {
                // No snapshot and no error — nothing to do
                return
            }

            var loaded: [RequestModel] = []

            for document in querySnapshot.documents {
                let data = document.data()

                let title = data["title"] as? String ?? "No Title"
                let id = (data["requestID"] as? String) ?? (data["creatorID"] as? String) ?? document.documentID
                let category = data["category"] as? String ?? "General"
                let status = data["status"] as? String ?? "Pending"

                let timestamp = (data["date"] as? Timestamp) ?? (data["created"] as? Timestamp) ?? (data["releaseDate"] as? Timestamp)
                let dateObject = timestamp?.dateValue() ?? Date()

                let newRequest = RequestModel(
                    title: title,
                    id: id,
                    category: category,
                    date: dateObject,
                    status: status
                )

                loaded.append(newRequest)
            }

            // Update storage and reapply any active filter
            self.allRequests = loaded
            // Apply all filters and sort
            DispatchQueue.main.async {
                self.applyFiltersAndSort()
            }
        }
    }

    // TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! StudStaffRequestCard
        let req = requests[indexPath.row]
        
        let timeString = req.date.timeAgoDisplay()
        
        cell.configure(
            title: req.title,
            id: req.id,
            category: req.category,
            date: timeString,
            status: req.status
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    
//    // Navigation Logic (Opens the new page)
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let selectedRequest = requests[indexPath.row]
//        if let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: "ExpandedTicketDetails") as? ExpandedTicketDetailsViewController {
//            detailsVC.requestData = selectedRequest
//            self.navigationController?.pushViewController(detailsVC, animated: true)
//        }
//    }
}
// Date Extension to convert time to "time ago" format
extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
