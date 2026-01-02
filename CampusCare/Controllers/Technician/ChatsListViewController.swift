//
//  ChatsListViewController.swift
//  CampusCare
//
//  Created by Malak on 01/01/2026.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

struct ChatItem {
    let chatId: String
    let lastMessage: String
    let updatedAt: Date
    let users: [String] // [techId, userId]
}

class ChatsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var chats: [ChatItem] = []
    var listener: ListenerRegistration?
    
    let db = Firestore.firestore()
    
    var currentTechId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        // Register default UITableViewCell with identifier "ChatCell"
           tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChatCell")
        fetchChats()
    }
    
    deinit {
        listener?.remove()
    }
    
    func fetchChats() {
        guard let techId = currentTechId else {
            print("❌ No logged-in tech")
            return
        }
        
        listener = db.collection("Chats")
            .whereField("users", arrayContains: techId)
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error fetching chats: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.chats = documents.compactMap { doc in
                    let data = doc.data()
                    guard let lastMessage = data["lastMessage"] as? String,
                          let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue(),
                          let users = data["users"] as? [String] else { return nil }
                    
                    return ChatItem(chatId: doc.documentID,
                                    lastMessage: lastMessage,
                                    updatedAt: updatedAt,
                                    users: users)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = chats[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") ??
            UITableViewCell(style: .subtitle, reuseIdentifier: "ChatCell")
        
        // Determine the userId (the person tech chats with)
        let userId = chat.users.first { $0 != currentTechId } ?? "Unknown"
        
        cell.textLabel?.text = "User: \(userId)" // You can replace with user's name if you store it
        cell.detailTextLabel?.text = chat.lastMessage
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = chats[indexPath.row]
        guard let techId = currentTechId else { return }
        
        // The other user in the chat
        let userId = chat.users.first { $0 != techId } ?? ""
        
        let storyboard = UIStoryboard(name: "Technician", bundle: nil)
        let chatVC = storyboard.instantiateViewController(
            withIdentifier: "ChatViewController"
        ) as! ChatViewController
        
        chatVC.currentUserId = techId
        chatVC.receiverId = userId
        chatVC.chatId = chat.chatId
        
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
