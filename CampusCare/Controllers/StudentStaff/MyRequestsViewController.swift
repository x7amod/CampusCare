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
    
    // Using global RequestModel from RequestModel.swift (no local struct needed)
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
        
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        
        TableView.dataSource = self
        TableView.delegate = self
        TableView.separatorStyle = .none
        // Hide scroll indicators
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
        let statusMenu = createStatusMenu()
        let categoryMenu = createCategoryMenu()
        let sortByMenu = createSortByMenu()
        let sortOrderMenu = createSortOrderMenu()
        
        filterButton.menu = UIMenu(title: "", children: [statusMenu, categoryMenu, sortByMenu, sortOrderMenu])
        filterButton.showsMenuAsPrimaryAction = true
    }
    
    private func createStatusMenu() -> UIMenu {
        let statuses: [(String, String?)] = [
            ("All Statuses", nil),
            ("Pending", "Pending"),
            ("Assigned", "Assigned"),
            ("In-Progress", "In-Progress"),
            ("Complete", "Complete"),
            ("Escalated", "Escalated")
        ]
        let actions = statuses.map { title, value in
            UIAction(title: title, state: selectedStatus == value ? .on : .off) { [weak self] _ in
                self?.selectedStatus = value
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            }
        }
        return UIMenu(title: "Filter by Status", options: [], children: actions)
    }
    
    private func createCategoryMenu() -> UIMenu {
        let categories: [(String, String?)] = [
            ("All Categories", nil),
            ("AC", "AC"),
            ("Electrical", "Electrical"),
            ("Network", "Network"),
            ("IT", "IT"),
            ("Building/Structural", "Building/Structural"),
            ("Plumbing", "Plumbing"),
            ("Safety/Equipment", "Safety/Equipment")
        ]
        let actions = categories.map { title, value in
            UIAction(title: title, state: selectedCategory == value ? .on : .off) { [weak self] _ in
                self?.selectedCategory = value
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            }
        }
        return UIMenu(title: "Filter by Category", options: [], children: actions)
    }
    
    private func createSortByMenu() -> UIMenu {
        let options: [(String, SortOption)] = [
            ("Time Submitted", .timeSubmitted),
            ("Last Update", .lastUpdate)
        ]
        let actions = options.map { title, value in
            UIAction(title: title, state: sortBy == value ? .on : .off) { [weak self] _ in
                self?.sortBy = value
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            }
        }
        return UIMenu(title: "Sort By", options: [], children: actions)
    }
    
    private func createSortOrderMenu() -> UIMenu {
        let options: [(String, SortOrder)] = [
            ("Ascending", .ascending),
            ("Descending", .descending)
        ]
        let actions = options.map { title, value in
            UIAction(title: title, state: sortOrder == value ? .on : .off) { [weak self] _ in
                self?.sortOrder = value
                self?.setupFilterMenu()
                self?.applyFiltersAndSort()
            }
        }
        return UIMenu(title: "Sort Order", options: [], children: actions)
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
                // Use the releaseDate field
                dateA = a.releaseDate.dateValue()
                dateB = b.releaseDate.dateValue()
            case .lastUpdate:
                // Use assignedDate if available, otherwise fall back to releaseDate
                dateA = a.assignedDate?.dateValue() ?? a.releaseDate.dateValue()
                dateB = b.assignedDate?.dateValue() ?? b.releaseDate.dateValue()
            }
            
            return sortOrder == .ascending ? dateA < dateB : dateA > dateB
        }
        
        // Update both the data and UI on main thread atomically to prevent race conditions
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Update data and reload in a single atomic operation
            self.requests = filtered
            self.TableView.reloadData()
        }
    }

    // Fetch from Firebase
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
                // show alert to user about failing to connect to db
                
                return
            }

            guard let querySnapshot = querySnapshot else {
                return
            }

            var loaded: [RequestModel] = []

            for document in querySnapshot.documents {
                // Use the RequestModel's initializer from document
                if let request = RequestModel(from: document) {
                    loaded.append(request)
                }
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
        
        // Safety check to prevent index out of range (idk why but sometimes happens)
        guard indexPath.row < requests.count else {
            print("[MyRequests] cellForRowAt error: Index \(indexPath.row) out of range for requests array (count: \(requests.count))")
            return cell
        }
        
        let req = requests[indexPath.row]
        
        let timeString = req.releaseDate.dateValue().timeAgoDisplay()
        
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
    
    // Navigation Logic (Opens the details page with correct storyboard identifier)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Safety check to prevent index out of range
        guard indexPath.row < requests.count else {
            print("[MyRequests] Error: Index \(indexPath.row) out of range for requests array (count: \(requests.count))")
            return
        }
        
        let selectedRequest = requests[indexPath.row]
        if let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: "RequestDetailsStudStaff") as? ExpandedTicketDetailsViewController {
            detailsVC.requestData = selectedRequest
            detailsVC.modalPresentationStyle = .pageSheet
            self.present(detailsVC, animated: true)
        }
    }
}
