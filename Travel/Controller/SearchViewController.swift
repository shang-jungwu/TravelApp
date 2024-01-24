//
//  ViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/17.
//

import UIKit
import SnapKit
import Alamofire
import SPAlert

class SearchViewController: UIViewController {

    var tripAdvisorPlaceData = [PlaceData]()
    var travelData = [TravelData]()
    var yelpData = [YelpApiData]()
    
    private let fetchApiDataUtility = FetchApiDataUtility()
    
    lazy var searchResultVC = SearchResultViewController()
        
    lazy var searchTextFieldStack = UIStackView()
    lazy var searchQueryTextField = TravelCustomTextField()
    lazy var categoryTextField = TravelCustomTextField()
    lazy var languageTextField = TravelCustomTextField()
    
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
//        getPlace() { [weak self] in
//            guard let self = self else { return }
//            // task finished, print data to examine
//            print("count: \(self.travelData.count)")
//        }
       getYelpData()
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
        searchQueryTextField.text = "新竹"
        textFieldSetting(searchQueryTextField, placeholder: "輸入地點", keyboard: .default)
        
        categoryTextField.text = "restaurants"
        textFieldSetting(categoryTextField, placeholder: "搜尋類別", keyboard: .default)
        languageTextField.text = "en"
        textFieldSetting(languageTextField, placeholder: "顯示語言", keyboard: .default)
    }
    
    func setupStackView() {
        searchTextFieldStack.axis = .vertical
        searchTextFieldStack.distribution = .equalSpacing
        searchTextFieldStack.spacing = 20
        
        setupTextField()
        searchTextFieldStack.addArrangedSubview(searchQueryTextField)
        searchTextFieldStack.addArrangedSubview(categoryTextField)
        searchTextFieldStack.addArrangedSubview(languageTextField)
    }
    
    func fetchYelpApiData(completion: @escaping((Result<YelpApiData,Error>) -> Void)) {
        
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer 5bP0Nd3XrOHvq6Jy3RBDLkF6PgtlmeeU3LaO-MQ-_py2jYKLoPHXIeGvuBtfgOfHC0xsQ_GR-_jEsFl1K17i_oeAgPfwLkcvNnTjTXSud_DH-hBrNZBYv2EJ3XewZXYx"
        ]

        let url = "https://api.yelp.com/v3/businesses/search"
        let parameters: Parameters = [
            "location": "新竹",
            "term": "restaurants",
            "sort_by": "best_match",
            "limit": 20
        ]

        AF.request(url, method: .get, parameters: parameters, headers: headers).response { response in
            if let data = response.data {
                print("data:\(data)")
                let decoder = JSONDecoder()
                do {
                    print("here~~~1")
                    let decodedData = try decoder.decode(YelpApiData.self, from: data)

                    completion(.success(decodedData))

                } catch {
                    if let error = response.error {
                        print("here~~~2")
                        completion(.failure(error))
                    }
                }
            }
        }
        
       
    }
    
    func getYelpData() {
        print("here~~~3")
        fetchYelpApiData { [weak self] result in
            guard let self = self else { return } // 避免強引用
            switch result {
                
            case .success(let data):
                print("here~~~4")
                self.yelpData.append(data)
                print("self.yelpData:\(self.yelpData)")
               
                if let nav = self.navigationController {
                    // passing data
                    searchResultVC.yelpData = self.yelpData
                    nav.pushViewController(searchResultVC, animated: true)
                }
                
            case .failure(let error):
                print("here~~~5")
                print("Error:\(error)")
            }
        }
    }
        
  
    func fetchTripAdvisorData(completion: @escaping (Result<[PlaceData],Error>) -> Void) {
        guard searchQueryTextField.text != "", categoryTextField.text != "", languageTextField.text != "" else {
            AlertKitAPI.present(title: "搜尋欄位不可為空", subtitle: nil, icon: .error, style: .iOS16AppleMusic, haptic: .warning)
            return
        }
        
        if let searhQuery = searchQueryTextField.text, let category = categoryTextField.text, let language = languageTextField.text {
            if let url = fetchApiDataUtility.prepareURL(forDataType: .search, loactionid: nil, searchQuery: searhQuery, category: category, language: language)  {
                
                AF.request(url).response { response in
                    if let data = response.data {
                        let decoder = JSONDecoder()
                        do {
                            let decodedData = try decoder.decode(TripAdvisorApi.self, from: data)
                            completion(.success(decodedData.data))
                        } catch {
                            if let error = response.error {
                                print("fail to decode~~~~")
                                completion(.failure(error))

                            }
                        }
                    }
                }
            }
        }
    }
    
    func getPlace(completion: @escaping (() -> Void)) {
        fetchTripAdvisorData { [weak self] result in
            guard let self = self else { return } // 避免強引用
            
            let alertView = AlertAppleMusic16View(title: "Searching~~~", subtitle: nil, icon: .spinnerLarge)
            alertView.present(on: self.view)
            
            switch result {
            case .success(let tripAdvisorApiData):
                alertView.dismiss() // 成功後關掉 alertView
                print("fetch successfully~~~~")
                
                self.tripAdvisorPlaceData = tripAdvisorApiData
                for data in tripAdvisorApiData {
                    self.travelData.append(TravelData(placeData: data))
                }
                
                if let nav = self.navigationController {
//                    self.searchResultVC.travelData = self.travelData
                    print("push searchResultVC~~~~")
                    nav.pushViewController(searchResultVC, animated: true)
                }
                
//                var counter = 0
//                for (i,placeData) in tripAdvisorPlaceData.enumerated() {
//                    self.travelData.append(TravelData(placeData: placeData))
                    // 先停抓照片 節省api扣打
//                    let locationID = placeData.locationID
//                    getPhoto(locationid: locationID) { [weak self] result in
//                        guard let self = self else { return } // 避免強引用
//                        
//                        counter += 1
//                        switch result {
//                        case .success(let photo):
//                            self.travelData[i].photoURL =  photo.images.small.url
//                            
//                            print("get photo success")
//                            
//                            if counter == self.tripAdvisorPlaceData.count {
//                                // success
//                                completion()
//                            }
////                            self.resultTableView.reloadData()
//                        case .failure(let error):
//                            print(error)
//                        }
//                    }
//                }
                
            case .failure(let error):
                print("fetch unsuccessfully~~~~")
                print("error:\(error)")
            }
        }
    }

//    func fetchPhoto(loactionid: String, completion: @escaping (Result<[PhotoData],Error>) -> Void) {
//                
//        if let url = fetchApiDataUtility.prepareURL(forDataType: .photo, loactionid: loactionid, searchQuery: nil, category: nil, language: "zh-TW") {
//            
//            AF.request(url).response { response in
//                if let data = response.data {
//                    let decoder = JSONDecoder()
//                    do {
//                        let decodedData = try decoder.decode(TripAdvisorPhotoApi.self, from: data)
//                        completion(.success(decodedData.data))
//                    } catch {
//                        if let error = response.error {
//                            print("photo~~API failure~~")
//                            completion(.failure(error))
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    
//    func getPhoto(locationid: String, completion: @escaping ((Result<PhotoData, Error>) -> Void)) {
//            fetchPhoto(loactionid: locationid) { result in
//                switch result {
//                case .success(let photoData):
//                    completion(.success(photoData[0]))
//                    
//                case .failure(let error):
//                    print("error:\(error)")
//                }
//            }
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

