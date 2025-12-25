//
//  CloudinaryManager.swift
//  CampusCare
//
//  Created by BP-36-201-05 on 25/12/2025.
//

import Foundation
import Cloudinary
import UIKit

class CloudinaryManager {

    static let shared = CloudinaryManager() // Singleton instance

    private let cloudName = "ducxhdkkd"
    private let uploadPreset = "student_upload_preset"

    private var cloudinary: CLDCloudinary

    private init() {
        let config = CLDConfiguration(cloudName: cloudName, secure: true)
        cloudinary = CLDCloudinary(configuration: config)
    }


    func uploadPDF(_ pdfData: Data, fileName: String, completion: @escaping (URL?) -> Void) {
           let params = CLDUploadRequestParams()
           params.setResourceType(.raw)
           params.setPublicId(fileName)

           cloudinary.createUploader().upload(data: pdfData, uploadPreset: uploadPreset, params: params) { response, error in
               if let urlString = response?.secureUrl, let url = URL(string: urlString) {
                   completion(url)
               } else {
                   print("Cloudinary PDF upload error: \(error?.localizedDescription ?? "Unknown error")")
                   completion(nil)
               }
           }
       }
}
