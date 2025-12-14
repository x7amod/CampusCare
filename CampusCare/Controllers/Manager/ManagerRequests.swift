//
//  TechRequests.swift
//  CampusCare
//
//  Created by BP-36-201-14 on 29/11/2025.
//

import UIKit
import FirebaseFirestore

class ManagerRequests: UIViewController {

    let requestCollection = RequestCollection()
    var requests: [RequestModel] = []
    
    @IBOutlet weak var stackVIew: UIStackView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as! CampusCareHeader
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        view.addSubview(headerView)
        
        // Set page-specific title
        headerView.setTitle("Requests Pool")// Change this for each screen

        // StackView top padding
        stackVIew.layoutMargins = UIEdgeInsets(top: 130, left: 0, bottom: 0, right: 0)
        stackVIew.isLayoutMarginsRelativeArrangement = true
        
        // search Bar
        searchBar.delegate = self

        FetchRequests()
    }
    
    //  fetch All
    func FetchRequests() {
        requestCollection.fetchAllRequests { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self?.requests = list
                    print("Fetched \(list.count) requests")
                    self?.reloadStackView()
                    
                case .failure(let error):
                    print("Error fetching requests: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // ui reload
    func reloadStackView() {
        stackVIew.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for r in requests {
            let item = RequestItemView.instantiate()
            item.configure(with: r)
            
            // Add tap to open details screen
            item.onTap = { [weak self] in
                guard let self = self else { return }

                let storyboard = UIStoryboard(name: "TechManager", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "MangerDetails") as! MangerDetails

                // Pass the request to the detail vc
                vc.request = r

                // Present modally
                vc.modalPresentationStyle = .fullScreen 
                self.present(vc, animated: true)
            }



            item.translatesAutoresizingMaskIntoConstraints = false
            item.heightAnchor.constraint(equalToConstant: 140).isActive = true
            stackVIew.addArrangedSubview(item)
        }
    }
}

// search Bar Delegate
extension ManagerRequests: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        requestCollection.searchRequests(prefix: searchText) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self?.requests = list
                    self?.reloadStackView()
                    
                case .failure(let error):
                    print("Search error: \(error.localizedDescription)")
                }
            }
        }
    }
}
