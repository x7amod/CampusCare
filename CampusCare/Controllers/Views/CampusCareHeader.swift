//
//  CampusCareHeader.swift
//  CampusCare
//
//  Created by BP-36-201-14 on 29/11/2025.
//

import Foundation
import UIKit
class CampusCareHeader: UIView{
    @IBOutlet weak var titleLabel :UILabel!
  //  @IBOutlet weak var backButton :UIButton!
  //  @IBOutlet weak var notificationIcon: :UIImageView!
        @IBOutlet weak var headerView: UIView!
    
    
    // Public method to set title from any view controller
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    
    }

