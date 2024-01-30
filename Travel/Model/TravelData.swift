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
    var time: Date
    
    init(placeData: Business, isSaved: Bool = false, time: Date = Date()) {
        self.placeData = placeData
        self.isSaved = isSaved
        self.time = time
    }
}
