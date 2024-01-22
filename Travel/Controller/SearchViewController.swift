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
        getPlace()
       
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
        searchQueryTextField.text = "新竹市"
        textFieldSetting(searchQueryTextField, placeholder: "輸入地點", keyboard: .default)
        
        categoryTextField.text = "hotels"
        textFieldSetting(categoryTextField, placeholder: "搜尋類別", keyboard: .default)
        languageTextField.text = "zh-TW"
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
    

    
//    func getURLString(searchQuery: String, language: String = "en") -> String {
//
//        let string = "https://api.content.tripadvisor.com/api/v1/location/search?key=AF48615F85EB441CB66C36342C521A6A&searchQuery=\(searchQuery)&language=\(language)"
//
//        return string
//    }
    
  
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
                            print("decoded~~~~")
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
    
    func getPlace() {
        fetchTripAdvisorData { [weak self] result in
            guard let self = self else { return } // 避免強引用
            
            var alertView = AlertAppleMusic16View(title: "Searching~~~", subtitle: nil, icon: .spinnerLarge)
            alertView.present(on: self.view)
            
            switch result {
            case .success(let tripAdvisorApiData):
                print("fetch successfully~~~~")
                self.tripAdvisorPlaceData = tripAdvisorApiData
                alertView.dismiss()
               
                if let nav = self.navigationController {
                    self.searchResultVC.tripAdvisorPlaceData = self.tripAdvisorPlaceData
                    nav.pushViewController(self.searchResultVC, animated: true)
                    print("Push SearchResultVC")
                }
                
            case .failure(let error):
                print("fetch unsuccessfully~~~~")
                print("error:\(error)")
            }
        }
    }

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

