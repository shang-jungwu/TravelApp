//
//  TravelData.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/19.
//

import Foundation

struct TravelData {
    let placeData: Datum
    var isSaved: Bool
    let photoURL: String
    
    init(placeData: Datum, isSaved: Bool = false, photoURL: String = "") {
        self.placeData = placeData
        self.isSaved = isSaved
        self.photoURL = photoURL
    }
}
