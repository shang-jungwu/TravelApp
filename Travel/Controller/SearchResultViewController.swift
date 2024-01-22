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

class SearchResultViewController: UIViewController {

    var tripAdvisorPlaceData = [PlaceData]()
    var tripAdvisorPhotoData = [PhotoData]()
    var travelData = [TravelData]()
    
    private let fetchApiDataUtility = FetchApiDataUtility()
    
    lazy var resultTableView = UITableView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), style: .grouped)
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupNav()
        setupUI()
        setupResultTableView()
        
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
        
        for (i,placeData) in tripAdvisorPlaceData.enumerated() {
            self.travelData.append(TravelData(placeData: placeData))
            
            // 先停抓照片 節省api扣打
//            let locationID = placeData.locationID
//            getPhoto(locationid: locationID) { [weak self] result in
//                guard let self = self else { return } // 避免強引用
//                switch result {
//                case .success(let photo):
//                    self.travelData[i].photoURL =  photo.images.medium.url
//                    self.resultTableView.reloadData()
//                case .failure(let error):
//                    print(error)
//                }
//            }
            
        }
       
    }

    func fetchPhoto(loactionid: String, completion: @escaping (Result<[PhotoData],Error>) -> Void) {
                
        if let url = fetchApiDataUtility.prepareURL(forDataType: .photo, loactionid: loactionid, searchQuery: nil, category: nil, language: "zh-TW") {
            
            AF.request(url).response { response in
                if let data = response.data {
                    let decoder = JSONDecoder()
                    do {
                        let decodedData = try decoder.decode(TripAdvisorPhotoApi.self, from: data)
                        completion(.success(decodedData.data))
                    } catch {
                        if let error = response.error {
                            print("photo~~API failure~~")
                            completion(.failure(error))
                        }
                    }
                }
            }
        }

    }

    func getPhoto(locationid: String, completion: @escaping ((Result<PhotoData, Error>) -> Void)) {
        fetchPhoto(loactionid: locationid) { result in
            switch result {
            case .success(let photoData):
                completion(.success(photoData[0]))
            case .failure(let error):
                print("error:\(error)")
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.resultTableView.reloadData()
    }

} // class end

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        travelData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        guard travelData.indices.contains(index), let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableViewCell", for: indexPath) as? SearchResultTableViewCell else { return UITableViewCell() }
        
        // SearchResultTableViewCellDelegate
        cell.delegate = self
        cell.indexPath = indexPath

        /////////////////////////////////////
            
        // 先停抓照片 節省api扣打
//        if let url = URL(string: travelData[index].photoURL) {
//            cell.placeImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "default_Image"))
//        }
        
        
        cell.placeImageView.image = UIImage(named: "default_Image")
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
//            cell.heartButton.backgroundColor = .systemRed
        } else {
            cell.heartButton.isSelected = false
//            cell.heartButton.backgroundColor = UIColor.init(white: 1, alpha: 0.2)
        }
    }
    
    
    
} // table view ex end

extension SearchResultViewController: SearchResultTableViewCellDelegate {

    func resultWasSaved(indexPath: IndexPath) {
        let index = indexPath.row
        guard travelData.indices.contains(index) else { return }
        
        var placeSavedStatus = travelData[index].isSaved
        placeSavedStatus = !placeSavedStatus // toggle
        travelData[index].isSaved = placeSavedStatus // 更新資料
        
        print("travelData[index]:\(travelData[index])")
        
        if placeSavedStatus == true {
            print("收藏")
        } else {
            print("退出")
        }
        
        resultTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
}
