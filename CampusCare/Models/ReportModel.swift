//
//  ReportModel.swift
//  CampusCare
//
//  Created by BP-36-201-05 on 25/12/2025.
//


import Foundation
import FirebaseFirestore

struct ReportModel {
    let id: String
    let url: String
    let releaseDate: Timestamp
}

extension ReportModel {
    init?(from document: DocumentSnapshot) {
        let data = document.data() ?? [:]
        
        guard
            let url = data["pdfURL"] as? String,
            let releaseDate = data["releaseDate"] as? Timestamp
        else {
            return nil
        }
        
        self.id = document.documentID
        self.url = url
        self.releaseDate = releaseDate
    }
}
