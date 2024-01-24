//
//  YelpApiData.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/24.
//

import Foundation

struct YelpApiData: Codable {
    let businesses: [Business]
    let total: Int
    let region: Region
}

// MARK: - Business
struct Business: Codable {
    let id, alias, name: String
    let imageURL: String
    let isClosed: Bool
    let url: String
    let reviewCount: Int
    let categories: [Category]
    let rating: Double
    let coordinates: Center

    let location: Location
    let phone, displayPhone: String
    let distance: Double
    let price: String?

    enum CodingKeys: String, CodingKey {
        case id, alias, name
        case imageURL = "image_url"
        case isClosed = "is_closed"
        case url
        case reviewCount = "review_count"
        case categories, rating, coordinates, location, phone
        case displayPhone = "display_phone"
        case distance, price
    }
}

// MARK: - Category
struct Category: Codable {
    let alias, title: String
}

// MARK: - Center
struct Center: Codable {
    let latitude, longitude: Double
}

// MARK: - Location
struct Location: Codable {
    let address1: String
    let address2: String?
    let address3: String?
    let city, zipCode: String
    let country: String
    let state: State
    let displayAddress: [String]

    enum CodingKeys: String, CodingKey {
        case address1, address2, address3, city
        case zipCode = "zip_code"
        case country, state
        case displayAddress = "display_address"
    }
}


enum State: String, Codable {
    case hsq = "HSQ"
    case hsz = "HSZ"
    case mia = "MIA"
    case tao = "TAO"
}

// MARK: - Region
struct Region: Codable {
    let center: Center
}

