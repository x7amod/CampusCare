//
//  NotificationCell.swift
//  CampusCare
//
//  Created by m1 on 17/12/2025.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    static let identifier = "NotificationCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardDesign()
    }

    private func setupCardDesign() {
        // Transparent background for the cell itself
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        // Card styling
        cardContainerView.layer.cornerRadius = 12
        cardContainerView.layer.masksToBounds = false
        
        // drop shadow (might need adjustment)
        cardContainerView.layer.shadowColor = UIColor.black.cgColor
        cardContainerView.layer.shadowOpacity = 0.1
        cardContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardContainerView.layer.shadowRadius = 4
    }

    func configure(requestID: String, title: String, status: String, time: String) {
        titleLabel.text = "\(requestID) - \(title)"
        statusLabel.text = status
        timeLabel.text = time
    }
}
