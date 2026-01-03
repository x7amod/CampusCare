//
//  StudStaffViewController.swift
//  CampusCare
//
//  Created by BP-36-201-14 on 29/11/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class Home: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
// Malak
    
    
    @IBAction func chatButtonTapped(_ sender: UIButton) {
          
          let storyboard = UIStoryboard(name: "StudStaff", bundle: nil)
              let vc = storyboard.instantiateViewController(
                  withIdentifier: "ChooseTechViewController"
              )

            navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func chatBotTapped(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "StudStaff", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "ChatBotViewController") as? ChatBotViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
    }
    
    
    
    //end of malak work
    
              
    
    @IBOutlet weak var recentRequestTableView: UITableView!
    @IBOutlet weak var announcementImage: UIImageView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var announcementStackView: UIStackView!
    
    private var recentRequests: [RequestModel] = []
    private let requestCollection = RequestCollection()
    private let announcementsCollection = AnnouncementsCollection()
    private let usersCollection = UsersCollection.shared
    private let imageCache = ImageCacheManager.shared
    
    // Announcement cycling properties
    private var announcements: [AnnouncementModel] = []
    private var loadedImages: [UIImage] = []
    private var currentAnnouncementIndex: Int = 0
    private var announcementTimer: Timer?
    private let announcementInterval: TimeInterval = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupAnnouncementImageView()
        fetchRecentRequests()
        fetchAnnouncements()
        updateGreeting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRecentRequests()
        startAnnouncementTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnnouncementTimer()
    }
    
    deinit {
        stopAnnouncementTimer()
    }
    
    // MARK: - Setup Methods
    
    private func setupTableView() {
        recentRequestTableView.dataSource = self
        recentRequestTableView.delegate = self
        recentRequestTableView.separatorStyle = .none
        recentRequestTableView.isScrollEnabled = false
        
        // Register StudStaffRequestCard cell
        recentRequestTableView.register(UINib(nibName: "StudStaffRequestCard", bundle: nil), forCellReuseIdentifier: "RequestCell")
    }
    
    private func setupAnnouncementImageView() {
        announcementImage?.contentMode = .scaleAspectFill
        announcementImage?.clipsToBounds = true
        announcementImage?.layer.cornerRadius = 14
    }
    
    // MARK: - Data Fetching
    
    private func fetchRecentRequests() {
        // Get current user ID from UserStore (primary) or Auth (fallback)
        guard let userID = UserStore.shared.currentUserID ?? Auth.auth().currentUser?.uid else {
            print("[Home] Error: No user ID available. User must be logged in.")
            DispatchQueue.main.async {
                self.showSimpleAlert(title: "Error", message: "Unable to fetch recent requests. Please log in again.")
            }
            return
        }
        
        requestCollection.fetchRecentRequests(userID: userID, limit: 2) { [weak self] result in
            switch result {
            case .success(let recentRequests):
                DispatchQueue.main.async {
                    self?.recentRequests = recentRequests
                    self?.recentRequestTableView.reloadData()
                }
                
            case .failure(let error):
                print("[Home] Error fetching recent requests: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.showSimpleAlert(title: "Error", message: "Failed to fetch recent requests.")
                }
            }
        }
    }
    
    private func fetchAnnouncements() {
        //print("[Home] Fetching announcements...")
        
        announcementsCollection.fetchActiveAnnouncements { [weak self] result in
            switch result {
            case .success(let announcements):
                //print("[Home] Received \(announcements.count) active announcements")
                
                guard !announcements.isEmpty else {
                    print("[Home] No active announcements to display")
                    DispatchQueue.main.async {
                        self?.announcementImage?.image = nil
                    }
                    return
                }
                
                self?.announcements = announcements.sorted()
                self?.preloadAnnouncementImages()
                
            case .failure(let error):
                print("[Home] Error fetching announcements: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.announcementImage?.image = nil
                }
            }
        }
    }
    
    private func preloadAnnouncementImages() {
        let group = DispatchGroup()
        var downloadedImages: [Int: UIImage] = [:]
        
        for (index, announcement) in announcements.enumerated() {
            group.enter()
            imageCache.downloadImage(from: announcement.imageURL) { image in
                if let image = image {
                    downloadedImages[index] = image
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            // Create ordered array of images
            self.loadedImages = (0..<self.announcements.count).compactMap { downloadedImages[$0] }
            
            // Display first image
            if let firstImage = self.loadedImages.first {
                self.announcementImage?.image = firstImage
                
                // Start cycling if more than one image
                if self.loadedImages.count > 1 {
                    self.startAnnouncementTimer()
                }
            }
        }
    }
    
    private func updateGreeting() {
        guard let userID = UserStore.shared.currentUserID else {
            greetingLabel?.text = "Greetings!"
            return
        }
        
        usersCollection.fetchUserFirstName(userID: userID) { [weak self] firstName in
            DispatchQueue.main.async {
                if let firstName = firstName {
                    self?.greetingLabel?.text = "Hello \(firstName)!"
                } else {
                    self?.greetingLabel?.text = "Greetings!"
                }
            }
        }
    }
    
    // MARK: - Announcement Timer
    
    private func startAnnouncementTimer() {
        stopAnnouncementTimer()
        
        guard loadedImages.count > 1 else { return }
        
        announcementTimer = Timer.scheduledTimer(withTimeInterval: announcementInterval, repeats: true) { [weak self] _ in
            self?.showNextAnnouncement()
        }
    }
    
    private func stopAnnouncementTimer() {
        announcementTimer?.invalidate()
        announcementTimer = nil
    }
    
    private func showNextAnnouncement() {
        guard !loadedImages.isEmpty, let imageView = announcementImage else { return }
        
        let nextIndex = (currentAnnouncementIndex + 1) % loadedImages.count
        let nextImage = loadedImages[nextIndex]
        
        // Use built-in transition animation
        UIView.transition(with: imageView,
                         duration: 0.35,
                         options: .transitionCrossDissolve,
                         animations: {
            imageView.image = nextImage
        }, completion: nil)
        
        currentAnnouncementIndex = nextIndex
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
        
        // Determine which storyboard ID to use based on status
        let storyboardIdentifier: String
        switch selectedRequest.status {
        case "Pending", "New":
            storyboardIdentifier = "PendingRequestPage"
        case "Assigned", "Escalated":
            storyboardIdentifier = "AssignedRequestPage"
        case "In-Progress":
            storyboardIdentifier = "InProgressRequestPage"
        case "Complete":
            storyboardIdentifier = "CompleteRequestPage"
        default:
            // Fallback to pending for unknown statuses
            storyboardIdentifier = "PendingRequestPage"
        }
        
        if let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: storyboardIdentifier) as? RequestDetailsBaseViewController {
            detailsVC.requestData = selectedRequest
            self.navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
}

