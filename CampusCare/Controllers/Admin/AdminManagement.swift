//
//  AdminManagementViewController.swift
//  CampusCare
//
//  Created by BP-36-201-14 on 29/11/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class AdminManagement: UIViewController {
    
    
   @IBOutlet weak var pageStepper: UIStepper!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var usersviews: UIStackView!
        
    /*
        private var allUsers: [UserModel] = []
        private var visibleUsers: [UserModel] = []

   
        private let cardsPerPage = 5
        private var currentPage = 0

        private var totalPages: Int {
            max(1, Int(ceil(Double(visibleUsers.count) / Double(cardsPerPage))))
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            title = "Admin"
            setupHeader()
    

            view.backgroundColor = .systemGray6

               // ✅ StackView setup (same feel as Requests Pool)
               usersviews.axis = .vertical
               usersviews.alignment = .fill
               usersviews.distribution = .fill
               usersviews.spacing = 10

               usersviews.isLayoutMarginsRelativeArrangement = true
               usersviews.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

             
               pageStepper.minimumValue = 0
               pageStepper.stepValue = 1

               loadAllUsers()

           }
        // Header
    func setupHeader() {
        // Do any additional setup after loading the view.
        let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as! CampusCareHeader
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        view.addSubview(headerView)
        
        // Set page-specific title
        headerView.setTitle("User Management")
        
    }
        

        // Load users (from UsersCollection)
        private func loadAllUsers() {
            UsersCollection.shared.fetchAllUsers { [weak self] users in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.allUsers = users
                    self.applyFiltersAndReload()
                }
            }
        }

        // filtter
        private func applyFiltersAndReload() {
            visibleUsers = allUsers

            currentPage = 0
            configureStepper()
            showPage(0, animated: false)
            updatePageLabel()
        }

        @IBAction func stepperChanged(_ sender: UIStepper) {
            showPage(Int(sender.value), animated: true)
            updatePageLabel()
        }

        private func configureStepper() {
            pageStepper.maximumValue = Double(max(0, totalPages - 1))
            pageStepper.value = Double(currentPage)
            pageStepper.isEnabled = totalPages > 1
        }

        private func updatePageLabel() {
            let current = min(totalPages, max(1, currentPage + 1))
            pageLabel.text = "Page \(current) of \(totalPages)"
        }

        // New page Replace cards
        private func showPage(_ page: Int, animated: Bool) {
            guard !visibleUsers.isEmpty else {
                clearCards()
                pageLabel.text = "Page 0 of 0"
                return
            }

            currentPage = max(0, min(page, totalPages - 1))
            pageStepper.value = Double(currentPage)

            let rebuild = {
                self.clearCards()

                let start = self.currentPage * self.cardsPerPage
                let end = min(start + self.cardsPerPage, self.visibleUsers.count)

                for i in start..<end {
                    let card = self.makeUserCard(user: self.visibleUsers[i])
                    self.usersviews.addArrangedSubview(card)
                }
            }

            if animated {
                UIView.animate(withDuration: 0.15, animations: {
                    self.usersviews.alpha = 0
                }, completion: { _ in
                    rebuild()
                    UIView.animate(withDuration: 0.20) {
                        self.usersviews.alpha = 1
                    }
                })
            } else {
                rebuild()
                usersviews.alpha = 1
            }
        }

        private func clearCards() {
            usersviews.arrangedSubviews.forEach {
                usersviews.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
        }

    private func makeUserCard(user: UserModel) -> UIView {

        let card = UIControl()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .systemBackground

        
        card.layer.cornerRadius = 20
        card.clipsToBounds = false

        // very soft shadow (like Requests Pool)
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.20;        card.layer.shadowRadius = 12
        card.layer.shadowOffset = CGSize(width: 0, height: 6)

        //card height
        card.heightAnchor.constraint(equalToConstant: 100).isActive = true

        
        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 20, weight: .bold)
        nameLabel.textColor = .label
        nameLabel.text = "\(user.FirstName) \(user.LastName)"
        nameLabel.numberOfLines = 1

        let roleLabel = UILabel()
        roleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        roleLabel.textColor = .secondaryLabel
        roleLabel.text = "\(user.Role)"
        roleLabel.numberOfLines = 1

        let stack = UIStackView(arrangedSubviews: [nameLabel, roleLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(stack)

        // ✅ IMPORTANT: top-left alignment (this removes the “big empty block” look)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -22),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 28)
        ])

        
        card.addAction(UIAction { [weak self] _ in
            self?.openUserDetails(user: user)
        }, for: .touchUpInside)

        return card
    }

          
    
    private func openUserDetails(user: UserModel) {
        let storyboard = UIStoryboard(name: "Admin", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "UserInfoViewController") as? UserInfoViewController else{return}
        
        vc.user = user
        vc.modalPresentationStyle = .fullScreen
        //present(vc, animated: true)
        
        navigationController?.pushViewController(vc, animated: true)

            
        }
    }


    
    */
    
    
    
    
    private var allUsers: [UserModel] = []
    private var visibleUsers: [UserModel] = []
    let usersCollection = UsersCollection()
    //private var selectedRole: String = "All"
  //  private var searchText: String = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupHeader()
        loadAllUsers()
    }
    
    func setupHeader() {
        // Do any additional setup after loading the view.
        let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as! CampusCareHeader
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        view.addSubview(headerView)
        
        // Set page-specific title
        headerView.setTitle("User Management")
        
    }
    
    
    func loadAllUsers() {
        usersCollection.fetchAllUsers { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self?.allUsers = list
                    self?.visibleUsers = list
                    print("Fetched \(list.count) Users")
                    self?.reloadStackView()
         
                case .failure(let error):
                print("Error fetching requests: \(error.localizedDescription)")
                }
            }
     
        }
     }
     
    func reloadStackView(){
     usersviews.arrangedSubviews.forEach { $0.removeFromSuperview() }
     for user in visibleUsers {
     let item = UserItemView.instantiate()
     item.configure(with: user)
     
     // Add tap to open details screen
     item.onTap = { [weak self] in
         guard let self = self else { return }

         let storyboard = UIStoryboard(name: "Admin", bundle: nil)
         let vc = storyboard.instantiateViewController(withIdentifier: "UserInfoViewController") as! UserInfoViewController
      

         // Pass the request to the detail vc
         //RequestStore.shared.currentRequest = r

         if let nav = self.navigationController {
             nav.pushViewController(vc, animated: true)
         } else {
             // fallback to modal if no navigation controller
             DispatchQueue.main.async {
                 vc.modalPresentationStyle = .fullScreen
                 self.present(vc, animated: true)
             }
         }
     }
     
                
     item.translatesAutoresizingMaskIntoConstraints = false
     item.heightAnchor.constraint(equalToConstant: 140).isActive = true
     usersviews.addArrangedSubview(item)
 }
}
}
    
    /*
    private func applyFilters() {
        //show all
        visibleUsers = allUsers
        
        view.layoutIfNeeded()
        buildUserPages()
        configureStepper()
        resetToFirstPage()

    }
    
    private func buildUserPages() {
        guard isViewLoaded else { return}
        // 1️⃣ Remove old pages
        usersviews.arrangedSubviews.forEach {
            usersviews.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let cardsPerPage = 5
        let totalPages = Int(ceil(Double(visibleUsers.count) / Double(cardsPerPage)))

        // 2️⃣ Create pages
        for pageIndex in 0..<totalPages {

            let pageView = UIView()
            pageView.translatesAutoresizingMaskIntoConstraints = false
          /*  pageView.heightAnchor
                .constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
                .isActive = true*/


            // Stack INSIDE page
            let pageStack = UIStackView()
            pageStack.axis = .vertical
            pageStack.spacing = 12
            pageStack.alignment = .fill
            pageStack.distribution = .fill
            pageStack.translatesAutoresizingMaskIntoConstraints = false

            pageView.addSubview(pageStack)

            NSLayoutConstraint.activate([
                pageStack.topAnchor.constraint(equalTo: pageView.topAnchor, constant: 16),
                pageStack.leadingAnchor.constraint(equalTo: pageView.leadingAnchor, constant: 16),
                pageStack.trailingAnchor.constraint(equalTo: pageView.trailingAnchor, constant: -16),
                pageStack.bottomAnchor.constraint(lessThanOrEqualTo: pageView.bottomAnchor, constant: -16)
            ])

            // 3️⃣ Add cards to page
            let start = pageIndex * cardsPerPage
            let end = min(start + cardsPerPage, visibleUsers.count)

            for i in start..<end {
                let card = makeUserCard(user: visibleUsers[i])
                pageStack.addArrangedSubview(card)
            }

            usersviews.addArrangedSubview(pageView)
        }
    }
    
    
    private func makeUserCard(user: UserModel) -> UIControl {

        let card = UIControl()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 14
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 88).isActive = true
        

        // Shadow (like your request cards)
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowRadius = 10
        card.layer.shadowOffset = CGSize(width: 0, height: 6)

        // Left labels
        let nameLabel = UILabel()
        nameLabel.text = "\(user.FirstName) \(user.LastName)"
        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        nameLabel.numberOfLines = 1

        let subLabel = UILabel()
        subLabel.text = user.Department
        subLabel.font = .systemFont(ofSize: 13)
        subLabel.textColor = .secondaryLabel
        subLabel.numberOfLines = 1

        let leftStack = UIStackView(arrangedSubviews: [nameLabel, subLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 4
        leftStack.translatesAutoresizingMaskIntoConstraints = false

        // Role badge on right
        let badge = UILabel()
        badge.text = user.Role
        badge.font = .systemFont(ofSize: 14, weight: .semibold)
        badge.textAlignment = .center
        badge.textColor = .white
        badge.backgroundColor = roleColor(user.Role)
        badge.layer.cornerRadius = 14
        badge.clipsToBounds = true
        badge.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            badge.widthAnchor.constraint(greaterThanOrEqualToConstant: 90),
            badge.heightAnchor.constraint(equalToConstant: 34)
        ])

        let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrow.tintColor = .tertiaryLabel
        arrow.translatesAutoresizingMaskIntoConstraints = false

        let rightStack = UIStackView(arrangedSubviews: [badge, arrow])
        rightStack.axis = .horizontal
        rightStack.alignment = .center
        rightStack.spacing = 10
        rightStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(leftStack)
        card.addSubview(rightStack)

        NSLayoutConstraint.activate([
            leftStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            leftStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            leftStack.trailingAnchor.constraint(lessThanOrEqualTo: rightStack.leadingAnchor, constant: -12),

            rightStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            rightStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
        ])

        // Tap action
       /*card.addAction(UIAction { [weak self] _ in
            self?.openUserDetails(user: user)
        }, for: .touchUpInside)*/

        return card
    }

    private func roleColor(_ role: String) -> UIColor {
        switch role.lowercased() {
        case "student": return .systemBlue
        case "staff": return .systemIndigo
        case "technician": return .systemOrange
        case "manager": return .systemRed
        case "admin": return .systemPurple
        default: return .systemGray
        }
        
        
        }
   
    
    func scrollToPage(_ page: Int) {
        view.layoutIfNeeded()
        let yOffset = CGFloat(page) * scrollView.bounds.height
        scrollView.setContentOffset(CGPoint(x: 0, y:yOffset), animated: true)
    }
    
    func configureStepper() {
        let pages = usersviews.arrangedSubviews.count
        pagescroll.minimumValue = 0
        pagescroll.maximumValue = Double(max(0, pages-1))
        pagescroll.stepValue = 1
        pagescroll.value = 0
    }
    
    @IBAction func pagescroll(_ sender: UIStepper){
        let page = Int(sender.value)
        scrollToPage(page)
    }
    
        
    func goToPage(_ page: Int) {
        pagescroll.value = Double(page)
        scrollToPage(page)
    }
    func resetToFirstPage() {
        view.layoutIfNeeded()
        pagescroll.value = 0
        scrollView.setContentOffset(.zero, animated: false)
    }
    //rearrange in case of change user count
    func reloadUsers() {
        buildUserPages()
        configureStepper()   //  update stepper again
        resetToFirstPage()
    }
   /* private func makeUserRow(user: UserModel) -> UIView {
        
        let container = UIControl()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 8
        container.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = "\(user.FirstName) \(user.LastName)"
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        let roleLabel = UILabel()
        roleLabel.text = user.Role
        roleLabel.font = .systemFont(ofSize: 13)
        roleLabel.textColor = .gray
        
        let vStack = UIStackView(arrangedSubviews: [nameLabel, roleLabel])
        vStack.axis = .vertical
        vStack.spacing = 12
        
        container.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            vStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        // Tap action
        container.addAction(UIAction { _ in
            self.openUserDetails(user: user)
        }, for: .touchUpInside)

        return container
    }*/
    
    private func openUserDetails(user: UserModel) {
        let storyboard = UIStoryboard(name: "Admin", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserInfoViewController") as! UserInfoViewController
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
        
        
            
            
        }
}*/
        
        
        
        
     
