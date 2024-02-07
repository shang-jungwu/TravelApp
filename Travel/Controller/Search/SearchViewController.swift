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

    
    private let uiSettingUtility = UISettingUtility()
    
    lazy var searchResultVC = SearchResultViewController()
    lazy var travelPersonImageView = UIImageView(image: UIImage(named: "stripy-message-sent"))
    lazy var searchTextFieldStack = UIStackView()
    lazy var locationTextField = TravelCustomTextField()
    lazy var termTextField = TravelCustomTextField()
    lazy var resultCountTextField = TravelCustomTextField()
    
    lazy var searchButton: UIButton = {
        let button = UIButton()
        button.setTitle("Search", for: [])
        button.setTitleColor(.white, for: [])
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.addTarget(self, action: #selector(pushSearchResultVC), for: .touchUpInside)
       return button
    }()
    
    @objc func pushSearchResultVC() {
        // MARK: - 先餵固定資料 省API次數
//               getYelpData()
        
        if let nav = self.navigationController {
            // passing data
            searchResultVC.travelData = restaurantData
            nav.pushViewController(searchResultVC, animated: true)
        }
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TravelAppColor.lightGrayBackgroundColor
        setupNav()
        setupUI()
        
    }

    func setupNav() {
        self.navigationItem.title = "Search"
        self.navigationController?.navigationBar.prefersLargeTitles = false
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
            make.leading.equalToSuperview().offset(100)
            make.trailing.equalToSuperview().offset(-100)
            make.height.equalTo(50)
        }
        
        view.addSubview(travelPersonImageView)
        travelPersonImageView.snp.makeConstraints { make in
            make.top.equalTo(searchButton.snp.bottom).offset(50)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }
    func setupTextField() {
        locationTextField.delegate = self
        locationTextField.text = "taipei"
        uiSettingUtility.textFieldSetting(locationTextField, placeholder: "輸入地點", keyboard: .default, autoCapitalize: .none)
        
        termTextField.delegate = self
        termTextField.text = "restaurant"
        uiSettingUtility.textFieldSetting(termTextField, placeholder: "搜尋類別", keyboard: .default, autoCapitalize: .none)
        
        resultCountTextField.delegate = self
        resultCountTextField.text = "20"
        uiSettingUtility.textFieldSetting(resultCountTextField, placeholder: "顯示筆數", keyboard: .numberPad, autoCapitalize: .none)
    }
    
    func setupStackView() {
        searchTextFieldStack.axis = .vertical
        searchTextFieldStack.distribution = .equalSpacing
        searchTextFieldStack.spacing = 20
        
        setupTextField()
        searchTextFieldStack.addArrangedSubview(locationTextField)
        searchTextFieldStack.addArrangedSubview(termTextField)
        searchTextFieldStack.addArrangedSubview(resultCountTextField)
    }
    
    func fetchYelpApiData(completion: @escaping((Result<[Business],Error>) -> Void)) {
        
        guard locationTextField.text != "", termTextField.text != "" else {
            AlertKitAPI.present(title: "搜尋欄位不可為空", subtitle: nil, icon: .error, style: .iOS16AppleMusic, haptic: .warning)
            return
        }
        
        if let location = locationTextField.text, let term = termTextField.text, let count = resultCountTextField.text {
            let headers: HTTPHeaders = [
                "accept": "application/json",
                "Authorization": "Bearer 5bP0Nd3XrOHvq6Jy3RBDLkF6PgtlmeeU3LaO-MQ-_py2jYKLoPHXIeGvuBtfgOfHC0xsQ_GR-_jEsFl1K17i_oeAgPfwLkcvNnTjTXSud_DH-hBrNZBYv2EJ3XewZXYx"
            ]

            let url = "https://api.yelp.com/v3/businesses/search"
            let parameters: Parameters = [
                "location": location,
                "term": term,
                "sort_by": "best_match",
                "limit": count
            ]

            AF.request(url, method: .get, parameters: parameters, headers: headers).response { response in
                if let data = response.data {
                    print("data:\(data)")
                    let decoder = JSONDecoder()
                    do {
                        let decodedData = try decoder.decode(YelpApiData.self, from: data)

                        completion(.success(decodedData.businesses))
                    } catch {
                        if let error = response.error {
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        travelData.removeAll()
    }
    
    func getYelpData() {
        fetchYelpApiData { [weak self] result in
            guard let self = self else { return } // 避免強引用
            
            let alertView = AlertAppleMusic16View(title: "Searching~~~", subtitle: nil, icon: .spinnerLarge)
            alertView.present(on: self.view)
            
            switch result {
            case .success(let data):
                alertView.dismiss() // 成功後關掉 alertView
                
                for bussiness in data {
                    self.travelData.append(TravelData(placeData: bussiness))
                }
               
                if let nav = self.navigationController {
                    // passing data
                    self.searchResultVC.travelData = self.travelData
                    print("self.travelData:\(self.travelData)")
                    nav.pushViewController(self.searchResultVC, animated: true)
                }
                
            case .failure(let error):
                print("Error:\(error)")
            }
        }
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        locationTextField.endEditing(true)
        termTextField.endEditing(true)
        resultCountTextField.endEditing(true)
    }

} // class end

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       self.view.endEditing(true)
   }

}


