//
//  StudStaffViewController.swift
//  CampusCare
//
//  Created by BP-36-201-14 on 29/11/2025.
//

import UIKit
import FirebaseFirestore

class Home: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var announcementView: UIView!
    @IBOutlet weak var recentRequestTableView: UITableView!
    @IBOutlet weak var imgPageControl: UIPageControl!
    @IBOutlet weak var announcementImage: UIImageView!
    @IBOutlet weak var greetingLabel: UILabel!
    
    private var recentRequests: [RequestModel] = []
    private let requestCollection = RequestCollection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        fetchRecentRequests()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh recent requests when view appears
        fetchRecentRequests()
    }
    
    private func setupTableView() {
        recentRequestTableView.dataSource = self
        recentRequestTableView.delegate = self
        recentRequestTableView.separatorStyle = .none
        recentRequestTableView.isScrollEnabled = false
        
        // Register StudStaffRequestCard cell
        recentRequestTableView.register(UINib(nibName: "StudStaffRequestCard", bundle: nil), forCellReuseIdentifier: "RequestCell")
    }
    
    private func fetchRecentRequests() {
        // Fetch all requests and get the 2 most recent
        requestCollection.fetchAllRequests { [weak self] result in
            switch result {
            case .success(let allRequests):
                // Sort by releaseDate descending and take first 2
                let sortedRequests = allRequests.sorted { $0.releaseDate.dateValue() > $1.releaseDate.dateValue() }
                let recentTwo = Array(sortedRequests.prefix(2))
                
                DispatchQueue.main.async {
                    self?.recentRequests = recentTwo
                    self?.recentRequestTableView.reloadData()
                }
            case .failure(let error):
                print("[Home] Error fetching recent requests: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! StudStaffRequestCard
        let request = recentRequests[indexPath.row]
        
        let timeString = request.releaseDate.dateValue().timeAgoDisplay()
        
        cell.configure(
            title: request.title,
            id: request.id,
            category: request.category,
            date: timeString,
            status: request.status
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedRequest = recentRequests[indexPath.row]
        if let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: "StudStaffExpandedTicketDetails") as? ExpandedTicketDetailsViewController {
            detailsVC.requestData = selectedRequest
            detailsVC.modalPresentationStyle = .pageSheet
            self.present(detailsVC, animated: true)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func newRequestTapped(_ sender: Any) {
        if let newRequestVC = self.storyboard?.instantiateViewController(withIdentifier: "NewRequestsStudStaff") {
            // Check if we have a navigation controller
            if let navController = self.navigationController {
                navController.pushViewController(newRequestVC, animated: true)
            } else {
                // Present modally if no navigation controller
                newRequestVC.modalPresentationStyle = .fullScreen
                self.present(newRequestVC, animated: true)
            }
        }
    }
    
    
}
