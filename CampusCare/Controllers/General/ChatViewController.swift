//
//  ChatViewController.swift
//  CampusCare
//
//  Created by Malak on 12/27/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ChatViewController: UIViewController,
                          UITableViewDelegate,
                          UITableViewDataSource,
                          UITextFieldDelegate {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!

    // MARK: - Properties
    var chatId: String?
    var currentUserId: String?
    var receiverId: String?

    var messages: [Message] = []
    var listener: ListenerRegistration?

    let db = Firestore.firestore()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // TableView setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
       // tableView.backgroundColor = UIColor.systemGray6


        // TextField setup
        messageTextField.delegate = self

        // Get current user
        currentUserId = Auth.auth().currentUser?.uid

        guard let currentUserId = currentUserId else {
            print("❌ No logged-in user")
            return
        }

        guard let receiverId = receiverId else {
            print("❌ receiverId not set")
            return
        }

        // 🔥 IMPORTANT FIX
        // Generate chatId ONLY if not passed (User vs Technician)
        if chatId == nil {
            chatId = generateChatId(user1: currentUserId, user2: receiverId)
        }

        print("🔥 Opening chat with ID:", chatId!)

        listenForMessages()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }

    // MARK: - TableView DataSource

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let message = messages[indexPath.row]

        // 🔥 IMPORTANT FIX: subtitle cell
        let cell = UITableViewCell(
            style: .subtitle,
            reuseIdentifier: "MessageCell"
        )

        cell.textLabel?.text = message.text
        cell.textLabel?.numberOfLines = 0

        cell.detailTextLabel?.text =
            message.senderId == currentUserId ? "You" : "Other"

        if message.senderId == currentUserId {
            cell.textLabel?.textAlignment = .right
            cell.detailTextLabel?.textAlignment = .right
        } else {
            cell.textLabel?.textAlignment = .left
            cell.detailTextLabel?.textAlignment = .left
        }

        return cell
    }

    // MARK: - Realtime Listener

    func listenForMessages() {
        guard let chatId = chatId else { return }

        listener = db.collection("Chats")
            .document(chatId)
            .collection("Messages") // capital M (as in Firebase)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in

                guard let self = self else { return }

                if let error = error {
                    print("❌ Listen error:", error.localizedDescription)
                    return
                }

                guard let documents = snapshot?.documents else { return }

                print("🔥 Messages fetched:", documents.count)

                self.messages = documents.compactMap { doc in
                    let data = doc.data()

                    guard
                        let senderId = data["senderId"] as? String,
                        let text = data["text"] as? String,
                        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
                    else { return nil }

                    return Message(
                        senderId: senderId,
                        text: text,
                        timestamp: timestamp
                    )
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()

                    if self.messages.count > 0 {
                        let indexPath = IndexPath(
                            row: self.messages.count - 1,
                            section: 0
                        )
                        self.tableView.scrollToRow(
                            at: indexPath,
                            at: .bottom,
                            animated: true
                        )
                    }
                }
            }
    }

    // MARK: - Send Message

    @IBAction func sendButtonTapped(_ sender: UIButton) {
        sendMessage()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }

    func sendMessage() {
        guard
            let text = messageTextField.text, !text.isEmpty,
            let currentUserId = currentUserId,
            let receiverId = receiverId,
            let chatId = chatId
        else {
            print("❌ Missing data")
            return
        }

        let messageData: [String: Any] = [
            "senderId": currentUserId,
            "text": text,
            "timestamp": Timestamp()
        ]

        let chatRef = db.collection("Chats").document(chatId)

        chatRef.collection("Messages").addDocument(data: messageData) { error in
            if let error = error {
                print("❌ Send error:", error.localizedDescription)
                return
            }

            chatRef.setData([
                "lastMessage": text,
                "updatedAt": Timestamp(),
                "users": [currentUserId, receiverId]
            ], merge: true)
        }

        messageTextField.text = ""
    }

    // MARK: - Helpers

    func generateChatId(user1: String, user2: String) -> String {
        return [user1, user2].sorted().joined(separator: "_")
    }
}

