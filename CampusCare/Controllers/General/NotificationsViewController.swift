//
//  NotificationsViewController.swift
//  CampusCare
//
//  Created by m1 on 26/12/2025.
//

import UIKit
import FirebaseFirestore

/// View controller responsible for displaying user notifications.
/// Embedded in a UINavigationController and uses a custom NotificationCell.
class NotificationsViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    /// Data source abstraction for notifications
    private let notificationsCollection = NotificationsCollection()
    
    /// In-memory storage for fetched notifications
    private var notifications: [NotificationModel] = []
    
    /// Real-time listener for notifications
    private var notificationListener: ListenerRegistration?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        setupRealTimeListener()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh notifications when view appears
        loadNotifications()
    }
    
    deinit {
        // Remove listener when view controller is deallocated
        notificationListener?.remove()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        title = "Notifications"
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        // Register custom cell
        let nib = UINib(nibName: "NotificationCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NotificationCellID")
        
        // Table styling
        tableView.separatorStyle = .none
        tableView.rowHeight = 104
        tableView.estimatedRowHeight = 104
        tableView.backgroundColor = .systemGroupedBackground
        
        // Remove empty cells
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Data Loading
    
    private func loadNotifications() {
        guard let userID = UserStore.shared.currentUserID else {
            print("[NotificationsVC]  Error: No logged-in user found")
            showErrorAlert(message: "Please log in to view notifications")
            return
        }

        notificationsCollection.fetchNotifications(for: userID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let notifications):
                    self?.notifications = notifications
                    self?.tableView.reloadData()
                    self?.updateEmptyState()
                    
                    // Auto-mark all notifications as read when page is viewed
                    self?.markAllNotificationsAsRead()
                    
                case .failure(let error):
                    print("[NotificationsVC]  Firestore fetch error: \(error.localizedDescription)")
                    print("[NotificationsVC]  Full error: \(error)")
                    self?.showErrorAlert(message: "Failed to load notifications: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Setup real-time listener for notifications
    private func setupRealTimeListener() {
        guard let userID = UserStore.shared.currentUserID else {
            print("[NotificationsVC] Error: No logged-in user for real-time listener")
            return
        }
        
        notificationListener = notificationsCollection.listenToNotifications(for: userID) { [weak self] notifications in
            DispatchQueue.main.async {
                self?.notifications = notifications
                self?.tableView.reloadData()
                self?.updateEmptyState()
            }
        }
    }
    
    // MARK: - Actions
    
    /// Automatically mark all notifications as read when user views the page
    private func markAllNotificationsAsRead() {
        guard let userID = UserStore.shared.currentUserID else { return }
        
        notificationsCollection.markAllAsRead(for: userID) { result in
            switch result {
            case .success:
                print("[NotificationsVC] All notifications marked as read")
            case .failure(let error):
                print("[NotificationsVC] Error marking all as read: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteNotification(at indexPath: IndexPath) {
        let notification = notifications[indexPath.section]
        
        // Show confirmation alert
        let alert = UIAlertController(
            title: "Delete Notification",
            message: "Are you sure you want to delete this notification?",
            preferredStyle: .alert
        )
        
        // Cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Delete action
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            // Proceed with deletion
            self?.notificationsCollection.deleteNotification(notificationID: notification.id) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("[NotificationsVC] Notification deleted successfully")
                        // Listener will automatically update the UI
                    case .failure(let error):
                        print("[NotificationsVC] Error deleting notification: \(error.localizedDescription)")
                        self?.showErrorAlert(message: "Failed to delete notification")
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    private func markNotificationAsRead(_ notification: NotificationModel) {
        guard !notification.isRead else { return }
        
        notificationsCollection.markAsRead(notificationID: notification.id) { result in
            switch result {
            case .success:
                print("[NotificationsVC] Notification marked as read")
                // Listener will automatically update the UI
            case .failure(let error):
                print("[NotificationsVC] Error marking as read: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleNotificationTap(_ notification: NotificationModel) {
        // Mark as read when tapped
        markNotificationAsRead(notification)
        
        // Navigate to request details page using the requestID
        navigateToRequestDetails(requestID: notification.requestID)
    }
    
    private func navigateToRequestDetails(requestID: String) {
        // Determine which storyboard to use based on user role
        guard let role = UserStore.shared.currentUserRole else { return }
        
        // For Student/Staff, fetch request first to determine which status-based page to show
        if role == "Student" || role == "Staff" {
            fetchAndShowRequestForStudentStaff(requestID: requestID)
            return
        }
        
        // For Manager role
        if role == "Manager" {
            let storyboard = UIStoryboard(name: "TechManager", bundle: nil)
            let detailsVC = storyboard.instantiateViewController(withIdentifier: "MangerRequest")
            navigationController?.pushViewController(detailsVC, animated: true)
            return
        }
        
        // For Technician role
        if role == "Technician" {
            let storyboard = UIStoryboard(name: "Technician", bundle: nil)
            let detailsVC = storyboard.instantiateViewController(withIdentifier: "Schedule")
            navigationController?.pushViewController(detailsVC, animated: true)
            return
        }
        
        // For Admin role no navigation as there is no notifications for admin
        if role == "Admin" {
            return
        }
    }
    
    private func fetchAndShowRequestForStudentStaff(requestID: String) {
        // Fetch the specific request by ID
        Firestore.firestore().collection("Requests").document(requestID).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[NotificationsVC] Error fetching request: \(error.localizedDescription)")
                    self?.showErrorAlert(message: "Failed to load request details")
                    return
                }
                
                guard let document = snapshot, document.exists,
                      let request = RequestModel(from: document) else {
                    print("[NotificationsVC] Request not found")
                    self?.showErrorAlert(message: "Request not found")
                    return
                }
                
                // Determine which storyboard ID to use based on status
                let storyboardIdentifier: String
                switch request.status {
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
                
                let storyboard = UIStoryboard(name: "StudStaff", bundle: nil)
                guard let detailsVC = storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as? RequestDetailsBaseViewController else {
                    print("[NotificationsVC] Failed to instantiate details VC with identifier: \(storyboardIdentifier)")
                    self?.showErrorAlert(message: "Failed to load request details page")
                    return
                }
                
                // Pass request data to details VC
                detailsVC.requestData = request
                
                // Use push navigation instead of modal
                self?.navigationController?.pushViewController(detailsVC, animated: true)
            }
        }
    }
    
    // MARK: - Empty State
    
    private func updateEmptyState() {
        if notifications.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }
    }
    
    private func showEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = "You have no notifications yet"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = .systemFont(ofSize: 17, weight: .regular)
        emptyLabel.numberOfLines = 0
        
        tableView.backgroundView = emptyLabel
        tableView.separatorStyle = .none
    }
    
    private func hideEmptyState() {
        tableView.backgroundView = nil
        tableView.separatorStyle = .none
    }
    
    // MARK: - Helper Methods
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension NotificationsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Each cell gets its own section for spacing
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "NotificationCellID",
            for: indexPath
        ) as? NotificationCell else {
            return UITableViewCell()
        }
        
        let notification = notifications[indexPath.section]
        cell.configure(with: notification)
        
        return cell
    }
    
    // Add spacing between cells height set = 10 for nice separation (since dumb xcode doesn't have an option)
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
}

// MARK: - UITableViewDelegate

extension NotificationsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let notification = notifications[indexPath.section]
        handleNotificationTap(notification)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Delete action
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.deleteNotification(at: indexPath)
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

