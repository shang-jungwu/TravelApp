//
//  ViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/17.
//

import UIKit
import SnapKit
import Alamofire
import GooglePlaces
import SPAlert

class SearchViewController: UIViewController {
    
//    enum FetchDataType: String {
//        case search = "search?"
//        case photo = "photo?"
//    }

//    var placeApiResult =  [Result]()
    var tripAdvisorPlaceData = [Datum]()
//    var tripAdvisorPhotoData = [PhotoDatum]()
    private let fetchApiDataUtility = FetchApiDataUtility()
    
    var photos = [UIImage]()
    lazy var searchResultVC = SearchResultViewController()
    
    private var placesClient: GMSPlacesClient!
    
    lazy var searchTextFieldStack = UIStackView()
    lazy var searchQueryTextField = TravelCustomTextField()
    lazy var categoryTextField = TravelCustomTextField()
//    lazy var languageTextField = TravelCustomTextField()
    
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
        getPlace()
       
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNav()
        setupUI()
        
//        placesClient = GMSPlacesClient.shared()

    }

    func setupNav() {
        self.navigationItem.title = "Search"
    }
    

    func setupUI() {
        setupStackView()
        view.addSubview(searchTextFieldStack)
        searchTextFieldStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(50)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            
        }
        
        view.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.top.equalTo(searchTextFieldStack.snp.bottom).offset(50)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
    }
    func setupTextField() {
        searchQueryTextField.text = "Taipei"
        textFieldSetting(searchQueryTextField, placeholder: "輸入地點", keyboard: .default)
        
        categoryTextField.text = "restaurants"
        textFieldSetting(categoryTextField, placeholder: "輸入類別", keyboard: .default)
//        languageTextField.text = "zh-TW"
//        textFieldSetting(languageTextField, placeholder: "language", keyboard: .default)
    }
    
    func setupStackView() {
        searchTextFieldStack.axis = .vertical
        searchTextFieldStack.distribution = .equalSpacing
        searchTextFieldStack.spacing = 20
        
        setupTextField()
        searchTextFieldStack.addArrangedSubview(searchQueryTextField)
        searchTextFieldStack.addArrangedSubview(categoryTextField)
//        searchTextFieldStack.addArrangedSubview(languageTextField)
    }
    
//    func prepareURL(forDataType: FetchDataType, loactionid: String?, searchQuery: String?, category: String?, language: String?) -> URL? {
//        
//        var urlComponents = URLComponents()
//        
//        switch forDataType {
//        case .search:
//            urlComponents = URLComponents(string: "https://api.content.tripadvisor.com/api/v1/location/\(forDataType.rawValue)")!
//        case .photo:
//            if let loactionid = loactionid  {
//                urlComponents = URLComponents(string: "https://api.content.tripadvisor.com/api/v1/location/\(loactionid)/\(forDataType.rawValue)")!
//            }
//
//        }
//       
//        let queryItems = [
//            ("key","AF48615F85EB441CB66C36342C521A6A"),
//            ("searchQuery",searchQuery),
//            ("category",category),
//            ("language",language)
//        ].filter({ (name,value) in
//            value != nil
//        })
//
//        urlComponents.queryItems = queryItems.map({ (name,value) in
//            URLQueryItem(name: name, value: value)
//        })
//        
//        return urlComponents.url
//    }
    
//    func getURLString(searchQuery: String, language: String = "en") -> String {
//
//        let string = "https://api.content.tripadvisor.com/api/v1/location/search?key=AF48615F85EB441CB66C36342C521A6A&searchQuery=\(searchQuery)&language=\(language)"
//
//        return string
//    }
    
    func fetchTripAdvisorData(completion: @escaping (Result<[Datum],Error>) -> Void) {
//        guard searchQueryTextField.text != "", categoryTextField.text != "" else { return }

        if let url = fetchApiDataUtility.prepareURL(forDataType: .search, loactionid: nil, searchQuery: "Taipei", category: "restaurants", language: "zh-TW")  {
            AF.request(url).response { response in
                if let data = response.data {
                    let decoder = JSONDecoder()
                    do {
                        let decodedData = try decoder.decode(TripAdvisorApi.self, from: data)
                        completion(.success(decodedData.data))
                    } catch {
                        if let error = response.error {
                            completion(.failure(error))

                        }
                    }
                }
            }
        }
    }
    
    func getPlace() {
        var alertView = AlertAppleMusic16View(title: "Searching~~~", subtitle: nil, icon: .spinnerLarge)
        alertView.present(on: self.view)
        
        fetchTripAdvisorData { [weak self] result in
            guard let self = self else { return } // 避免強引用
            switch result {
            case .success(let tripAdvisorApiData):
                self.tripAdvisorPlaceData = tripAdvisorApiData
                alertView.dismiss()
               
                if let nav = self.navigationController {
                    self.searchResultVC.tripAdvisorPlaceData = self.tripAdvisorPlaceData
                    nav.pushViewController(self.searchResultVC, animated: true)
                    print("Push SearchResultVC")
                }
                
            case .failure(let error):
                alertView = AlertAppleMusic16View(title: nil, subtitle: nil, icon: .error)
                alertView.present(on: self.view)
                print("error:\(error)")
            }
        }
    }
    
    
        
    
    
//    func getPlaceAPIData() {
//        var urlComponents = URLComponents(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?")!
//        urlComponents.queryItems = [
//            "location":"25.0338,121.5646",
//            "radius":"1000",
//            "type":"restaurant",
//            "language":"zh-TW",
//            "key":"AIzaSyDT0SGfWxNEZZqsISYtMUu8QFBh0F9qSY0"
//        ].map({
//            URLQueryItem(name: $0.key, value: $0.value)
//        })
//        
//        if let url = urlComponents.url {
//            AF.request(url).response { response in
//                if let apiData = response.data {
//                  let decoder = JSONDecoder()
//                    do {
//                        let result = try decoder.decode(PlaceApiData.self, from: apiData)
//                       
//                        self.placeApiResult = result.results
//                        print(self.placeApiResult.count)
//                      
//                    } catch  {
//                        print(response.error as Any)
//                    }
//                }
//            }
//        }
//
//    }


    func textFieldSetting(_ sender: TravelCustomTextField, placeholder: String, keyboard: UIKeyboardType) {
        sender.placeholder = placeholder
        sender.layer.cornerRadius = 15
        sender.layer.borderWidth = 2
        sender.layer.borderColor = UIColor.systemCyan.cgColor
        sender.keyboardType = keyboard
        sender.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
    
    

}

