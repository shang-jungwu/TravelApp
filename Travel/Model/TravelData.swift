//
//  TravelData.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/19.
//

import Foundation

struct TravelData {
    let placeData: PlaceData
    var isSaved: Bool
    var photoURL: String
    
    init(placeData: PlaceData, isSaved: Bool = false, photoURL: String = "") {
        self.placeData = placeData
        self.isSaved = isSaved
        self.photoURL = photoURL
    }
}
