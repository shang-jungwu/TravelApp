//
//  ViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/17.
//

import UIKit
import SnapKit
import Alamofire

class SearchViewController: UIViewController {

    var placeApiResult =  [Result]()
    lazy var searchResultVC = SearchResultViewController()
    
    lazy var searchButton: UIButton = {
        let button = UIButton()
        button.setTitle("Search", for: [])
        button.setTitleColor(.systemCyan, for: [])
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemCyan.cgColor
        button.addTarget(self, action: #selector(pushSearchResultVC), for: .touchUpInside)
       return button
    }()
    
    @objc func pushSearchResultVC() {
//        getPlaceAPIData()
        if let nav = self.navigationController {
            nav.pushViewController(searchResultVC, animated: true)
            print("Push SearchResultVC")
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNav()
        setupUI()
      
    }

    func setupNav() {
        self.navigationItem.title = "Search"
    }
    
    func setupUI() {
        view.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }
    
    
    
    func getPlaceAPIData() {
        var urlComponents = URLComponents(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?")!
        urlComponents.queryItems = [
            "location":"25.0338,121.5646",
            "radius":"1000",
            "type":"restaurant",
            "language":"zh-TW",
            "key":"AIzaSyDT0SGfWxNEZZqsISYtMUu8QFBh0F9qSY0"
        ].map({
            URLQueryItem(name: $0.key, value: $0.value)
        })
        
        if let url = urlComponents.url {
            AF.request(url).response { response in
                if let apiData = response.data {
                  let decoder = JSONDecoder()
                    do {
                        let result = try decoder.decode(PlaceApiData.self, from: apiData)
                       
                        self.placeApiResult = result.results
                        print(self.placeApiResult.count)
                        
                    } catch  {
                        print(response.error as Any)
                    }
                }
            }
        }

    }

    
    
    

}

