//
//  TripAdvisorPhotoApi.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/19.
//

import Foundation

// MARK: - TripAdvisorPhotoApi
struct TripAdvisorPhotoApi: Codable {
    let data: [PhotoDatum]
}

// MARK: - PhotoDatum
struct PhotoDatum: Codable {
    let id: Int
    let isBlessed: Bool
    let caption, publishedDate: String
    let images: Images
    let album: String
    let source: Source
    let user: User

    enum CodingKeys: String, CodingKey {
        case id
        case isBlessed = "is_blessed"
        case caption
        case publishedDate = "published_date"
        case images, album, source, user
    }
}

// MARK: - Images
struct Images: Codable {
    let thumbnail, small, medium, large: Large
    let original: Large
}

// MARK: - Large
struct Large: Codable {
    let height, width: Int
    let url: String
}

// MARK: - Source
struct Source: Codable {
    let name, localizedName: String

    enum CodingKeys: String, CodingKey {
        case name
        case localizedName = "localized_name"
    }
}

// MARK: - User
struct User: Codable {
    let username: String
}


