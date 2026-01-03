//
//  EmptyStateView.swift
//  CampusCare
//
//  Created by Reem on 03/01/2026.
//

import Foundation


import UIKit

class EmptyStateView: UIView {
    

    
    @IBOutlet weak var messageLabel: UILabel!
    
    //to center message if list is empty
    static func instantiate(message: String) -> EmptyStateView {
           let nib = UINib(nibName: "EmptyStateView", bundle: nil)
           let view = nib.instantiate(withOwner: nil, options: nil).first as! EmptyStateView
           view.messageLabel.text = message
           return view
       }
    
}
