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

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!

    
    var chatId: String?
    var currentUserId: String?
    var receiverId: String?

    var messages: [Message] = []
    var listener: ListenerRegistration?

    let db = Firestore.firestore()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TableView setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
       //tableView.backgroundColor = UIColor.systemGray6


     
        messageTextField.delegate = self

        // Get current user
        currentUserId = Auth.auth().currentUser?.uid

        guard let currentUserId = currentUserId else {
            print("No logged-in user")
            return
        }

        guard let receiverId = receiverId else {
            print("receiverId not set")
            return
        }

        
        if chatId == nil {
            chatId = generateChatId(user1: currentUserId, user2: receiverId)
        }

        print("Opening chat with ID:", chatId!)

        listenForMessages()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }



    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

   
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let message = messages[indexPath.row]

        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear

        // Bubble view
        let bubbleView = UIView()
        bubbleView.layer.cornerRadius = 16
        bubbleView.translatesAutoresizingMaskIntoConstraints = false

        // Message label
        let messageLabel = UILabel()
        messageLabel.text = message.text
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        bubbleView.addSubview(messageLabel)
        cell.contentView.addSubview(bubbleView)

        // Padding inside bubble
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 14),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -14)
        ])

  
        bubbleView.widthAnchor.constraint(
            lessThanOrEqualTo: cell.contentView.widthAnchor,
            multiplier: 0.75
        ).isActive = true

        if message.senderId == currentUserId {
            // Sent (right)
            bubbleView.backgroundColor = UIColor.systemBlue
            messageLabel.textColor = .white

            NSLayoutConstraint.activate([
                bubbleView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -12),
                bubbleView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 6),
                bubbleView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -6)
            ])
        } else {
            // Received (left)
            bubbleView.backgroundColor = UIColor.systemGray4
            messageLabel.textColor = .black

            NSLayoutConstraint.activate([
                bubbleView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 12),
                bubbleView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 6),
                bubbleView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -6)
            ])
        }

        return cell
    }

    

    // Realtime Listener

    func listenForMessages() {
        guard let chatId = chatId else { return }

        listener = db.collection("Chats")
            .document(chatId)
            .collection("Messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in

                guard let self = self else { return }

                if let error = error {
                    print("Listen error:", error.localizedDescription)
                    return
                }

                guard let documents = snapshot?.documents else { return }

                print("Messages fetched:", documents.count)

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
            print("Missing data")
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
                print("Send error:", error.localizedDescription)
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

   

    func generateChatId(user1: String, user2: String) -> String {
        return [user1, user2].sorted().joined(separator: "_")
    }
}

