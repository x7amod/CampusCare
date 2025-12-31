//
//  MyAccount.swift
//  CampusCare
//
//  Created by dar on 31/12/2025.
//

import UIKit

class MyAccount: UIViewController {

    @IBOutlet weak var tableview: UITableView!

    private enum Row: Int, CaseIterable {
        case resetPassword
        case logout

        var title: String {
            switch self {
            case .resetPassword: return "Reset Password"
            case .logout: return "Log Out"
            }
        }

        var iconSystemName: String {
            switch self {
            case .resetPassword: return "arrow.clockwise"
            case .logout: return "rectangle.portrait.and.arrow.right"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "My Account"

        tableview.dataSource = self
        tableview.delegate = self
        tableview.tableFooterView = UIView()
        tableview.isScrollEnabled = false

        // Bigger rows
        tableview.rowHeight = 64

        // Remove default separators (we'll space via sections)
        tableview.separatorStyle = .none
    }

    private func openResetPassword() {
        let sb = UIStoryboard(name: "More", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ResetPassword")
        navigationController?.pushViewController(vc, animated: true)
    }

    private func confirmLogout() {
        let alert = UIAlertController(title: nil,
                                      message: "Are you trying to logout?",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.logoutNow()
        })

        present(alert, animated: true)
    }

    private func logoutNow() {
        let result = FirebaseAuthService.shared.signOut()

        if case .failure(let error) = result {
            print("Sign out error: \(error.localizedDescription)")
        }

        navigationController?.popToRootViewController(animated: true)
    }
}

extension MyAccount: UITableViewDataSource, UITableViewDelegate {

    
    func numberOfSections(in tableView: UITableView) -> Int {
        Row.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath)

        guard let row = Row(rawValue: indexPath.section) else { return cell }

        var content = cell.defaultContentConfiguration()
        content.text = row.title
        content.textProperties.font = .systemFont(ofSize: 18, weight: .medium)

        content.image = UIImage(systemName: row.iconSystemName)
        content.imageProperties.tintColor = (row == .logout) ? .systemRed : .systemOrange
        content.imageProperties.maximumSize = CGSize(width: 26, height: 26)
        content.imageToTextPadding = 16

        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default

        if row == .logout {
            content.textProperties.color = .systemRed
            cell.contentConfiguration = content
        }

        
        cell.layer.cornerRadius = 12
        cell.clipsToBounds = true

        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        16
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let row = Row(rawValue: indexPath.section) else { return }

        switch row {
        case .resetPassword:
            openResetPassword()
        case .logout:
            confirmLogout()
        }
    }
}
