//
//  SearchResultViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/18.
//

import UIKit
import SnapKit
import SDWebImage
import Alamofire
//import GooglePlaces

class SearchResultViewController: UIViewController {

    var tripAdvisorPlaceData = [Datum]()
    var tripAdvisorPhotoData = [PhotoDatum]()
    var travelData = [TravelData]()

    private let fetchApiDataUtility = FetchApiDataUtility()
    
    lazy var resultTableView = UITableView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), style: .grouped)
    
//    private var placesClient: GMSPlacesClient!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupNav()
        setupUI()
        setupResultTableView()

//        placesClient = GMSPlacesClient.shared()
        
    }
    
    func setupNav() {
        self.navigationItem.title = "Result"
    }

    func setupUI() {
        view.addSubview(resultTableView)
        resultTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }
    
    func setupResultTableView() {
        resultTableView.delegate = self
        resultTableView.dataSource = self
        resultTableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: "SearchResultTableViewCell")
    }
    

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        for datum in tripAdvisorPlaceData {
            self.travelData.append(TravelData(placeData: datum))
        }
        
//        travelData = travelData.filter { travelData in
//            travelData.placeData.addressObj.country == "Taiwan"
//        }
        getPhoto()

    }

    func fetchPhoto(completion: @escaping (Result<[PhotoDatum],Error>) -> Void) {
        for i in 0..<tripAdvisorPlaceData.count {
            if let url = fetchApiDataUtility.prepareURL(forDataType: .photo, loactionid: tripAdvisorPlaceData[i].locationID, searchQuery: nil, category: nil, language: "zh-TW") {

                AF.request(url).response { response in
                    if let data = response.data {
                        let decoder = JSONDecoder()
                        do {
                            let decodedData = try decoder.decode(TripAdvisorPhotoApi.self, from: data)
                            completion(.success(decodedData.photoData))
                        } catch {
                            if let error = response.error {
                                completion(.failure(error))
                            }
                        }
                    }
                }
            }
        }

    }

    func getPhoto() {
        fetchPhoto { result in
            switch result {
            case .success(let photoData):
                self.tripAdvisorPhotoData = photoData
                for i in 0..<self.tripAdvisorPhotoData.count {
                    self.travelData[i].photoURL = photoData[i].images.medium.url
                }

                self.resultTableView.reloadData()
                print("photoData.count:\(photoData.count)")
            case .failure(let error):
                print("error:\(error)")
            }
        }
    }


} // class end

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        travelData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        guard travelData.indices.contains(index), let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableViewCell", for: indexPath) as? SearchResultTableViewCell else { return UITableViewCell() }

        if let url = URL(string: travelData[index].photoURL) {
            cell.backGroundImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "default_Image"))
        }

        cell.nameLabel.text = travelData[index].placeData.name
        
        updateHeartButtonUI(cell, placeIsSaved: travelData[index].isSaved)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        1
    }
    
    
    private func updateHeartButtonUI(_ cell: SearchResultTableViewCell, placeIsSaved: Bool) {
        if placeIsSaved {
            cell.heartButton.isSelected = true
        } else {
            cell.heartButton.isSelected = false
        }
    }
    
}

extension SearchResultViewController: SearchResultTableViewCellDelegate {

    func resultWasSaved(indexPath: IndexPath) {
        let index = indexPath.row
        guard travelData.indices.contains(index) else { return }
        
        var placeSavedStatus = travelData[index].isSaved
        placeSavedStatus = !placeSavedStatus // toggle
        travelData[index].isSaved = placeSavedStatus // 更新資料
        
        if placeSavedStatus == true {
            print("收藏")
        } else {
            print("退出")
        }
        
        resultTableView.reloadData()
    }
    
    
}
