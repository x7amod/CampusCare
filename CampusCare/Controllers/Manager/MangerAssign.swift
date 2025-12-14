//
//  MangerAssign.swift
//  CampusCare
//
//  Created by BP-36-201-09 on 14/12/2025.
//

import UIKit
import FirebaseFirestore

class MangerAssign: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Header setup
        if let headerView = Bundle.main.loadNibNamed("CampusCareHeader", owner: nil, options: nil)?.first as? CampusCareHeader {
            headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
            view.addSubview(headerView)
            headerView.setTitle("Request Assign")
        }
    }
}
