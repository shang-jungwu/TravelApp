//
//  Test.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/18.
//

import Foundation
import Alamofire

struct FetchApiDataUtility {

    enum FetchDataType: String {
        case search = "search?"
        case photo = "photos?"
    }
    
    func prepareURL(forDataType: FetchDataType, loactionid: String?, searchQuery: String?, category: String?, language: String?) -> URL? {

        var urlComponents = URLComponents()

        switch forDataType {
        case .search:
            urlComponents = URLComponents(string: "https://api.content.tripadvisor.com/api/v1/location/\(forDataType.rawValue)")!
        case .photo:
            if let loactionid = loactionid  {
                urlComponents = URLComponents(string: "https://api.content.tripadvisor.com/api/v1/location/\(loactionid)/\(forDataType.rawValue)")!
            }

        }

        let queryItems = [
            ("key","AF48615F85EB441CB66C36342C521A6A"),
            ("searchQuery",searchQuery),
            ("category",category),
            ("language",language)
        ].filter({ (name,value) in
            value != nil
        })

        urlComponents.queryItems = queryItems.map({ (name,value) in
            URLQueryItem(name: name, value: value)
        })
        return urlComponents.url
    }
    
    
    
}
