//
//  AdminViewController.swift
//  CampusCare
//
//  Created by BP-36-201-14 on 29/11/2025.
//

import UIKit
import FirebaseFirestore


class AdminAnalytics: UIViewController {
    
    //Outlit
    @IBOutlet weak var techNum: UILabel!
    @IBOutlet weak var reqNum: UILabel!
    private var requests: [RequestModel] = []
    
    private let usersCollection = UsersCollection()
    let requestCollection = RequestCollection()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeader() 
        fetchTechnicians()
        FetchRequests()
       
    }
    
    private func setupHeader() {
        // Do any additional setup after loading the view.
        let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as! CampusCareHeader
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        view.addSubview(headerView)
        
        // Set page-specific title
           headerView.setTitle("Analytics")  // Change this for each screen
    }
    
    private func fetchTechnicians() {
        usersCollection.fetchTechnicians { users in
            let techUsers = users.filter { $0.role == "Tech" }
            
            DispatchQueue.main.async {
                self.techNum.text = "\(techUsers.count)" // update the label with Tech count
            }
        }
    }

    
    private func FetchRequests() {
        requestCollection.fetchAllRequests { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let list):
                    let openRequests = list.filter { $0.status ?? "" != "Done" }
                    self.requests = openRequests
                    self.reqNum.text = "\(openRequests.count)"
                case .failure(let error):
                    print("Error fetching requests: \(error.localizedDescription)")
                }
            }
        }
    }


    }


   
    


