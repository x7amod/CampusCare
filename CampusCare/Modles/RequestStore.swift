//
//  RequestStore.swift
//  CampusCare
//
//  Created by BP-36-201-06 on 21/12/2025.
//

import Foundation

class RequestStore {
    static let shared = RequestStore()   // singleton
    private init() {}

    var currentRequest: RequestModel?    // store the request
}
