//
//  ChatBotViewController.swift
//  CampusCare
//
//  Created by Malak on 1/2/26.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ChatBotViewController: UIViewController,
                             UITableViewDelegate,
                             UITableViewDataSource,
                             UITextFieldDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!

    
    var messages: [BotMessage] = []

    let db = Firestore.firestore()

    var currentUserId: String = ""
    var currentUserName: String = ""

   
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        getCurrentUser()
    }

    
    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BotCell")

        messageTextField.delegate = self
    }

   
    func getCurrentUser() {
        guard let userId = Auth.auth().currentUser?.uid else {
            addMessage("Hello! Please log in to use the chatbot.", isUser: false)
            return
        }

        currentUserId = userId
        fetchCurrentUserName()
    }

  
    func fetchCurrentUserName() {
        db.collection("Users").document(currentUserId).getDocument { snapshot, error in
            guard let snapshot = snapshot,
                  snapshot.exists,
                  error == nil,
                  let data = snapshot.data()
            else {
                self.addMessage("Hello! I can help you with your maintenance requests.", isUser: false)
                return
            }

           
            if let name = data["First Name"] as? String {
                self.currentUserName = name
                self.addMessage("Hello \(name)! 👋 How can I help you today? Send help to list how can I assist you", isUser: false)
            } else {
                self.addMessage("Hello! How can I help you today?", isUser: false)
            }
        }
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

        // Max width
        bubbleView.widthAnchor.constraint(
            lessThanOrEqualTo: cell.contentView.widthAnchor,
            multiplier: 0.75
        ).isActive = true

        if message.isUser {
            // User (right)
            bubbleView.backgroundColor = .systemBlue
            messageLabel.textColor = .white

            NSLayoutConstraint.activate([
                bubbleView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -12),
                bubbleView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 6),
                bubbleView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -6)
            ])
        } else {
            // Bot (left)
            bubbleView.backgroundColor = .systemGray4
            messageLabel.textColor = .black

            NSLayoutConstraint.activate([
                bubbleView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 12),
                bubbleView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 6),
                bubbleView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -6)
            ])
        }

        return cell
    }


    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        sendMessage()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }

    func sendMessage() {
        guard let text = messageTextField.text, !text.isEmpty else { return }

        addMessage(text, isUser: true)
        messageTextField.text = ""

        handleUserMessage(text)
    }

    
    func addMessage(_ text: String, isUser: Bool) {
        messages.append(BotMessage(text: text, isUser: isUser))
        tableView.reloadData()
        scrollToBottom()
    }

    func scrollToBottom() {
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    
    func handleUserMessage(_ text: String) {
        let lowerText = text.lowercased()

        // Request-related
        if lowerText.contains("how many requests") {
            fetchUserRequestCount()
        } else if lowerText.contains("my requests") {
            fetchUserRequests()
        }
        // Generic
        else if let reply = handleGenericQuestion(lowerText) {
            addMessage(reply, isUser: false)
        }
        // Fallback
        else {
            addMessage("Sorry, I didn’t understand that. Type 'help' to see what I can do.", isUser: false)
        }
    }

    // MARK: - Generic Questions
    func handleGenericQuestion(_ text: String) -> String? {

        if text.contains("hi") || text.contains("hello") {
            return "Hi \(currentUserName)! 😊"
        }

        if text.contains("salam") || text.contains("salaam") || text.contains("السلام") {
            return "Wa alaykumu s-salam "
        }

        if text.contains("how are you") {
            return "I'm doing great 😊 How can I help you today?"
        }

        if text.contains("help") {
            return """
            I can help you with:
            • How many requests I submitted
            • Show my requests
            • How to make a request
            """
        }

        if text.contains("how to make") && text.contains("request") {
            return """
            To make a maintenance request:
            1️⃣ Go to the Home page
            2️⃣ Click on the "Add Request" button
            3️⃣ Fill in the form
            4️⃣ Submit the request ✅
            """
        }

        if text.contains("thank") {
            return "You're welcome! 😊"
        }

        return nil
    }



    
    func fetchUserRequestCount() {
        db.collection("requests")
            .whereField("creatorID", isEqualTo: currentUserId)
            .getDocuments { snapshot, error in

                guard let snapshot = snapshot, error == nil else {
                    self.addMessage("Unable to fetch requests.", isUser: false)
                    return
                }

                self.addMessage("You have submitted \(snapshot.documents.count) requests.", isUser: false)
            }
    }

    func fetchUserRequests() {
        db.collection("requests")
            .whereField("creatorID", isEqualTo: currentUserId)
            .getDocuments { snapshot, error in

                guard let snapshot = snapshot, error == nil else {
                    self.addMessage("Unable to fetch requests.", isUser: false)
                    return
                }

                let requests = snapshot.documents.compactMap {
                    RequestModel(from: $0)
                }

                if requests.isEmpty {
                    self.addMessage("You have no maintenance requests.", isUser: false)
                } else {
                    let list = requests.map { "• \($0.title) (\($0.status))" }
                                       .joined(separator: "\n")
                    self.addMessage("Here are your requests:\n\(list)", isUser: false)
                }
            }
    }
}
