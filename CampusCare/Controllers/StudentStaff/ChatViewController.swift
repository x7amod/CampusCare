//
//  ChatViewController.swift
//  CampusCare
//
//  Created by Malak on 12/27/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!

    // MARK: - Firebase
    let db = Firestore.firestore()
    var chatId: String!           // computed from user IDs
    var otherUserId: String!      // set this before opening ChatViewController
    var messages: [Message] = []
    var messagesListener: ListenerRegistration?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MessageCell")

        setupChat()
        startListeningMessages()
    }

    deinit {
        messagesListener?.remove()
    }

    // MARK: - Chat Setup
    func setupChat() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        // 1️⃣ Compute deterministic chatId
        chatId = chatIdFor(uid1: currentUserId, uid2: otherUserId)

        // 2️⃣ Ensure chat document exists
        let chatRef = db.collection("chats").document(chatId)
        chatRef.setData([
            "users": [currentUserId, otherUserId],
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    // Deterministic chatId for two users
    func chatIdFor(uid1: String, uid2: String) -> String {
        let (a, b) = uid1 < uid2 ? (uid1, uid2) : (uid2, uid1)
        return "\(a)_\(b)"
    }

    // MARK: - Sending Message
    @IBAction func sendTapped(_ sender: UIButton) {
        guard let text = messageTextField.text,
              !text.isEmpty,
              let senderId = Auth.auth().currentUser?.uid else { return }

        let chatRef = db.collection("chats").document(chatId)
        let messagesRef = chatRef.collection("messages")
        let newMessageRef = messagesRef.document()

        let messageData: [String: Any] = [
            "senderId": senderId,
            "text": text,
            "timestamp": FieldValue.serverTimestamp()
        ]

        // Batch write: add message + update chat's lastMessage
        let batch = db.batch()
        batch.setData(messageData, forDocument: newMessageRef)
        batch.setData([
            "lastMessage": text,
            "updatedAt": FieldValue.serverTimestamp()
        ], forDocument: chatRef, merge: true)

        batch.commit { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            }
        }

        messageTextField.text = ""
    }

    // MARK: - Listening for Messages
    func startListeningMessages() {
        messagesListener?.remove()
        messagesListener = db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }

                self.messages = documents.compactMap { doc in
                    let data = doc.data()
                    guard
                        let senderId = data["senderId"] as? String,
                        let text = data["text"] as? String,
                        let timestamp = data["timestamp"] as? Timestamp
                    else { return nil }

                    return Message(senderId: senderId, text: text, timestamp: timestamp.dateValue())
                }

                self.tableView.reloadData()
                if self.messages.count > 0 {
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
    }

    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        let message = messages[indexPath.row]

        // Display message text (can customize bubble later)
        cell.textLabel?.text = message.text
        return cell
    }
}

