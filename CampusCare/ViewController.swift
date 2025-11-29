//
//  ViewController.swift
//  CampusCare
//
//  Created by Guest User on 24/11/2025.
//

import UIKit
import FirebaseFirestore
import Cloudinary

class ViewController: UIViewController {
    


    let cloudName: String = "ducxhdkkd"
    var uploadPreset: String = "student_upload_preset" //NEW - Name of unsigned upload preset

    @IBOutlet weak var ivUploadedImage: CLDUIImageView! //NEW - Outlet for uploaded image

    var cloudinary: CLDCloudinary!

    override func viewDidLoad() {
        super.viewDidLoad()
        initCloudinary()
        uploadImage() //NEW - Call upload function
    }
    private func initCloudinary() {
        let config = CLDConfiguration(cloudName: cloudName, secure: true)
        cloudinary = CLDCloudinary(configuration: config)
    }
    //NEW - Upload function
    private func uploadImage() {
        guard let data = UIImage(named: "cloudinary_logo")?.pngData() else {
            return
        }
        cloudinary.createUploader().upload(data: data, uploadPreset: uploadPreset, completionHandler:  { response, error in
            DispatchQueue.main.async {
                guard let url = response?.secureUrl else {
                    return
                }
                self.ivUploadedImage.cldSetImage(url, cloudinary: self.cloudinary)
            }
        })
    }

}
