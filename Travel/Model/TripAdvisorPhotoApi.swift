//
//  TripAdvisorPhotoApi.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/19.
//

import Foundation

struct TripAdvisorPhotoApi: Codable {
    let photoData: [PhotoDatum]
}

// MARK: - Datum
struct PhotoDatum: Codable {
    let id: Int
    let caption, publishedDate: String
    let images: Images
    let user: User

    enum CodingKeys: String, CodingKey {
        case id
        case caption
        case publishedDate = "published_date"
        case images
        case user
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

// MARK: - User
struct User: Codable {
    let username: String
}
