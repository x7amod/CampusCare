//
//  TechDetails.swift
//  CampusCare
//
//  Reem on 22/12/2025.
//

import Foundation
import UIKit



class TechDetails: UIViewController {
    
    //mac n cheese
    var request: RequestModel?
    
    //components
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskLocation: UILabel!
    @IBOutlet weak var subDate: UILabel! //release date ?
    @IBOutlet weak var taskDescription: UILabel!
    @IBOutlet weak var taskCategory: UILabel!
    @IBOutlet weak var taskImg: UIImageView!
    @IBOutlet weak var taskStatus: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Setup UI first (optional styling)
               setupUI()
               
               // Populate data if request exists
               if let request = request {
                   populateData(with: request)
               } else {
                   // Fallback: Try to get from RequestStore
                   if let storedRequest = RequestStore.shared.currentRequest {
                       populateData(with: storedRequest)
                   } else {
                       print("Error: No request data available")
                       // Optionally show an error or go back
                   }
               }//pepsi
         }
      
    private func loadImage(from urlString: String) { //mac n cheese
            guard let url = URL(string: urlString) else { return }
            
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.taskImg.image = image
                    }
                }
            }
        }
        
    
    //pepsi
    private func setupUI() {
            // Add any visual styling here
            taskImg.layer.cornerRadius = 8
            taskImg.clipsToBounds = true
            
            taskStatus.layer.cornerRadius = 8
            taskStatus.clipsToBounds = true
        }
        
        private func populateData(with request: RequestModel) {
            // Set text values
            taskTitle.text = request.title
            taskLocation.text = request.location
            taskDescription.text = request.description
            taskCategory.text = request.category
            
            // Format and set dates
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            
            subDate.text = "Released: \(dateFormatter.string(from: request.releaseDate.dateValue()))"
            
            // Set status button
            taskStatus.setTitle("Status: \(request.status)", for: .normal)
            
            // Set status button color based on status
            switch request.status.lowercased() {
            case "new":
                taskStatus.backgroundColor = .systemBlue
            case "assigned":
                taskStatus.backgroundColor = .systemOrange
            case "in progress":
                taskStatus.backgroundColor = .systemYellow
            case "completed":
                taskStatus.backgroundColor = .systemGreen
            default:
                taskStatus.backgroundColor = .systemGray
            }
            
            // Load image if URL exists
           // if !request.imageURL.isEmpty, let url = URL(string: request.imageURL) {
            //    loadImage(from: url)
         //   } else {
          //      taskImg.image = UIImage(named: "placeholder") // Add a placeholder image to your assets
        //    }
        }
        
        
        
        
    } ///end
    ///
    ///
    
    
    
    
    
    
    //mac n cheese = good
//pepsi ?
    
    
    
    
    
    
    


