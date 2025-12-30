//
//  AdminMnagement.swift
//  CampusCare
//
//  Created by BP-36-201-14 on 29/11/2025.
//



import UIKit
import FirebaseAuth
import FirebaseFirestore

final class AdminManagement: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    private var allUsers: [UserModel] = []
    private var visibleUsers: [UserModel] = []
    private let usersCollection = UsersCollection()

    private var isLoading: Bool = false
    private var selectedRole: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchBar.showsCancelButton = false

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .clear

        tableView.register(UINib(nibName: "UserItemView", bundle: nil),
                           forCellReuseIdentifier: "UserItemView")

        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)

        setupFilterMenu()
        filterButton.tintColor = .black

        loadAllUsers()
    }
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           loadAllUsers()
       }
    private func loadAllUsers() {
        if isLoading { return }
        isLoading = true

        usersCollection.fetchAllUsers { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let list):
                    self.allUsers = list
                    self.applyFilters()
                case .failure(let error):
                    print("[AdminManagement] loadAllUsers error: \(error.localizedDescription)")
                }
            }
        }
    }

   
    private func setupFilterMenu() {
        let roleMenu = createRoleMenu()
        filterButton.menu = UIMenu(title: "", children: [roleMenu])
        filterButton.showsMenuAsPrimaryAction = true
    }

    private func createRoleMenu() -> UIMenu {
        let roles: [(String, String?)] = [
            ("All Users", nil),
            ("Student", "Student"),
            ("Staff", "Staff"),
            ("Technician", "Technician"),
            ("Manager", "Manager")
        ]

        let actions = roles.map { title, value in
            UIAction(title: title, state: selectedRole == value ? .on : .off) { [weak self] _ in
                self?.selectedRole = value
                self?.setupFilterMenu()
                self?.applyFilters()
            }
        }

        return UIMenu(title: "Filter By Role", children: actions)
    }

    //search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilters()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        applyFilters()
        searchBar.resignFirstResponder()
    }

    //search bar filter
    private func applyFilters() {
        var filtered = allUsers

        let text = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty {
            let lower = text.lowercased()
            filtered = filtered.filter { u in
                let fullName = "\(u.FirstName) \(u.LastName)".lowercased()
                return fullName.contains(lower)
                    || u.username.lowercased().contains(lower)
                    || u.Role.lowercased().contains(lower)
                    || u.Department.lowercased().contains(lower)
            }
        }

        if let role = selectedRole {
            filtered = filtered.filter { $0.Role == role }
        }

        visibleUsers = filtered
        tableView.reloadData()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserItemView", for: indexPath) as! UserItemView
        let user = visibleUsers[indexPath.row]

        cell.configure(with: user)

        
        cell.onTap = { [weak self] in
            self?.openUserInfo(user: user)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }

   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = visibleUsers[indexPath.row]
        openUserInfo(user: user)
    }

    
    private func openUserInfo(user: UserModel) {
        let storyboard = UIStoryboard(name: "Admin", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "UserInfoViewController") as? UserInfoViewController else {
            print("[AdminManagement] Could not instantiate UserInfoViewController")
            return
        }

        vc.user = user

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
}
