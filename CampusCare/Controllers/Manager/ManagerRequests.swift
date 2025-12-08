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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as! CampusCareHeader
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        view.addSubview(headerView)
        
        // Set page-specific title
           headerView.setTitle("Requests Pool")  // Change this for each screen
        
        FetchRequests()
    }
    
    
    func FetchRequests() {
            requestCollection.fetchAllRequests { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let list):
                        self?.requests = list
                        print("Fetched \(list.count) requests")
                        for r in list {
                            print("ID: \(r.id), Title: \(r.title)")
                        }
                    case .failure(let error):
                        print("❌ Error fetching requests: \(error.localizedDescription)")
                    }
                }
            }
        }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
