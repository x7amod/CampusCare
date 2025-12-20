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

    // Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var img: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupHeader()
        setupBackButton()
        populateRequestDetails()
    }
    
    //Header
    private func setupHeader() {
        if let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as? CampusCareHeader {
            headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
            view.addSubview(headerView)
            headerView.setTitle("Request Details")
        }
    }

    // back Button
    private func setupBackButton() {
        let backButton = UIButton(frame: CGRect(x: 16, y: 50, width: 60, height: 30))
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.systemBackground, for: .normal)
        backButton.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        view.addSubview(backButton)
    }

    // Populate Request
    private func populateRequestDetails() {
        guard let r = request else { return }

        titleLabel?.text = r.title
        idLabel?.text = r.id
        categoryLabel?.text = r.category
        roleLabel?.text = r.location
        timeLabel?.text = DateFormatter.localizedString(from: r.releaseDate.dateValue(), dateStyle: .medium, timeStyle: .none)
        priorityLabel?.text = r.priority

        // Image loading safely
        if !r.imageURL.isEmpty, let url = URL(string: r.imageURL) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async { [weak self] in
                        self?.img?.image = UIImage(data: data)
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.img?.image = UIImage(named: "defaultImage")
                    }
                }
            }
        } else {
            img?.image = UIImage(named: "defaultImage")
        }
        
        print(r.id)
    }

    //  show Assign VC
    @IBAction func showAssign(_ sender: Any) {
        // Instantiate Assign VC
        guard let assignVC = storyboard?.instantiateViewController(withIdentifier: "MangerAssign") as? MangerAssign else { return }
        guard let request = self.request else { return }

        // Pass the full request, not just ID
        assignVC.request = request
        print("Passing full request to Assign VC:", request.id)

        // Present modally directly (no async needed)
        assignVC.modalPresentationStyle = .fullScreen
        self.present(assignVC, animated: true)
    }

    
    // close
    @objc func closeVC() {
        dismiss(animated: true)
    }
}
