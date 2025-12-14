//
//  MangerDetails.swift
//  CampusCare
//
//  Created by BP-36-201-09 on 14/12/2025.
//


import UIKit
import FirebaseFirestore

class MangerDetails: UIViewController {

    var request: RequestModel?  // receives the data

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    //this still not work
    @IBAction func showAssign(_ sender: Any) {
        
        let assignVC = MangerAssign()
           assignVC.modalPresentationStyle = .fullScreen
           self.present(assignVC, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Header setup
        if let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as? CampusCareHeader {
            headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
            view.addSubview(headerView)
            headerView.setTitle("Request Details")
        }

        // set labels safely
        if let r = request {
            titleLabel?.text = r.title
            idLabel?.text = r.id
            categoryLabel?.text = r.category
            roleLabel?.text = r.location
            timeLabel?.text = DateFormatter.localizedString(from: r.releaseDate.dateValue(), dateStyle: .medium, timeStyle: .none)
            priorityLabel?.text = r.priority
        }

        // Back button
        let backButton = UIButton(frame: CGRect(x: 16, y: 50, width: 60, height: 30))
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.systemBackground, for: .normal)
        backButton.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        view.addSubview(backButton)
    }


    @objc func closeVC() {
        self.dismiss(animated: true)
    }
}
