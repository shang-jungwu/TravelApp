//
//  TravelData.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/19.
//

import Foundation

struct TravelData {
    let placeData: Business//PlaceData
    var isSaved: Bool
//    var photoURL: String // yelp offers imageURL
    
    init(placeData: Business, isSaved: Bool = false) {
        self.placeData = placeData
        self.isSaved = isSaved
//        self.photoURL = photoURL
    }
}
