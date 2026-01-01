//
//  StudStaffRequestCard.swift
//  CampusCare
//
//  Created by m1 on 17/12/2025.
//
import UIKit

class StudStaffRequestCard: UITableViewCell {

    // Container
    @IBOutlet weak var cardContainerView: UIView!
    // Labels
    @IBOutlet weak var titleLabel: UILabel!       // request title
    @IBOutlet weak var idLabel: UILabel!          // request ID
    @IBOutlet weak var typeLabel: UILabel!        // request type
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    // Status Badge
    @IBOutlet weak var statusContainerView: UIView!
    @IBOutlet weak var statusLabel: UILabel!      //  request status

    override func awakeFromNib() {
        super.awakeFromNib()
        setupDesign()
    }
    
    private func setupDesign() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none

        cardContainerView.layer.cornerRadius = 18
        cardContainerView.backgroundColor = .white
            
        // drop shadow TODO:  (might need adjustment)
        cardContainerView.layer.shadowColor = UIColor.black.cgColor
        cardContainerView.layer.shadowOpacity = 0.08
        cardContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardContainerView.layer.shadowRadius = 6
            
        statusContainerView.layer.cornerRadius = 16
    }
        
    func configure(title: String, id: String, category: String, date: String, status: String) {
        titleLabel.text = title
        idLabel.text = id
        typeLabel.text = category
        timeAgoLabel.text = date
        statusLabel.text = status
            
        // Apply the colors and the background based on status TODO: (might need to edit names based on db placeholders for now)
        switch status {
        case "Pending":
            statusContainerView.backgroundColor = UIColor(red: 120/255, green: 120/255, blue: 120/255, alpha: 0.75) // Gray
            statusLabel.textColor = .white
                
        case "In-Progress":
            statusContainerView.backgroundColor = UIColor(red: 14/255, green: 0.0, blue: 201/255, alpha: 1.0) // Deep Blue
            statusLabel.textColor = .white
                
        case "Complete":
            statusContainerView.backgroundColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1.0) // Green
            statusLabel.textColor = .white
                
        case "Assigned":
            statusContainerView.backgroundColor = UIColor(red: 230/255, green: 237/255, blue: 244/255, alpha: 1.0) // Light Gray
            statusLabel.textColor = .black // Black text for light background
        
        case "Escalated":
            statusContainerView.backgroundColor = .systemRed
            statusLabel.textColor = .white
                
        default:
            // Fallback for unknown status
            statusContainerView.backgroundColor = .lightGray
            statusLabel.textColor = .black
            }
        }
    }
