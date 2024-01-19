//
//  TripAdvisorApi.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/19.
//

import Foundation

struct TripAdvisorApi: Codable {
    let data: [Datum]
}

// MARK: - Datum
struct Datum: Codable {
    let locationID, name: String
    let addressObj: AddressObj

    enum CodingKeys: String, CodingKey {
        case locationID = "location_id"
        case name
        case addressObj = "address_obj"
    }
}

// MARK: - AddressObj
struct AddressObj: Codable {
    let street1, city, country: String
    let postalcode: String?
    let addressString: String
    let street2, state: String?

    enum CodingKeys: String, CodingKey {
        case street1, city, country, postalcode
        case addressString = "address_string"
        case street2, state
    }
}
