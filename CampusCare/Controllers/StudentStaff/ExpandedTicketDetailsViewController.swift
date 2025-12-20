//
//  ExpandedTicketDetailsViewController.swift
//  CampusCare
//
//  Created by m1 on 17/12/2025.
//
import UIKit

class ExpandedTicketDetailsViewController: UIViewController {

    // receive data from the previous screen
    var requestData: MyRequestsViewController.RequestModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white // Default background
        
        // Just for testing print what we received
        if let data = requestData {
            print("Opened details for: \(data.title)")
            
        }
    }
}
