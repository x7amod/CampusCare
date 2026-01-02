//
//  ChooseTechViewController.swift
//  CampusCare
//
//  Created by Malak on 12/31/25.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth

class ChooseTechViewController: UIViewController,
                               UITableViewDelegate,
                               UITableViewDataSource {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Properties
    let db = Firestore.firestore()
    var technicians: [UserModel] = []
    var currentUserId: String!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 🔥 THIS LINE FIXES THE CRASH
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TechCell")

        // Get current logged-in user ID
        currentUserId = Auth.auth().currentUser?.uid

        if currentUserId == nil {
            print("❌ No logged-in user")
            return
        }

        tableView.delegate = self
        tableView.dataSource = self

        loadTechnicians()
    }

    // MARK: - Firestore
    func loadTechnicians() {
        db.collection("Users")
                .whereField("Role", isEqualTo: "Technician")
                .getDocuments { snapshot, error in

                    if let error = error {
                        print("❌ Error loading technicians:", error.localizedDescription)
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        print("❌ No documents")
                        return
                    }

                    print("✅ Technicians count:", documents.count)

                    self.technicians = documents.compactMap {
                        UserModel(from: $0)
                    }

                    print("✅ Parsed technicians:", self.technicians.count)

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
          
    }

    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return technicians.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TechCell",
            for: indexPath
        )

        let tech = technicians[indexPath.row]
        cell.textLabel?.text = "\(tech.FirstName) \(tech.LastName)"

        return cell
    }

    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let technician = technicians[indexPath.row]
        openChat(with: technician)
    }

    // MARK: - Navigation
    func openChat(with technician: UserModel) {

        guard let currentUserId = currentUserId else {
            print("❌ Current user ID missing")
            return
        }

        let storyboard = UIStoryboard(name: "Technician", bundle: nil)
        let chatVC = storyboard.instantiateViewController(
            withIdentifier: "ChatViewController"
        ) as! ChatViewController

        chatVC.currentUserId = currentUserId
        chatVC.receiverId = technician.id

        navigationController?.pushViewController(chatVC, animated: true)
    }
}

