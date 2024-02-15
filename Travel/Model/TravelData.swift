//
//  TravelData.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/19.
//

import Foundation

struct TravelData: Codable {
    let placeData: Business
    var isSaved: Bool
    var time: TimeInterval//Date
    
    init(placeData: Business, isSaved: Bool = false, time: TimeInterval = Date().timeIntervalSince1970) {
        self.placeData = placeData
        self.isSaved = isSaved
        self.time = time
    }
}

struct TestTravelData: Codable {
    let placeName: String
    var time: TimeInterval//Date
    
    init(placeName: String, time: TimeInterval = Date().timeIntervalSince1970) {
        self.placeName = placeName
        self.time = time
    }
}
