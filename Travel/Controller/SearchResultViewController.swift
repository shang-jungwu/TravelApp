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
    
    var urlArr = [String]()

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
        let rightBarItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(photoGet))
        self.navigationItem.rightBarButtonItem = rightBarItem
    }
    
    @objc func photoGet() {
        getPhoto(loactionid: "0")
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
        
        for i in 0..<tripAdvisorPlaceData.count {
            let datum = tripAdvisorPlaceData[i]
            
            self.travelData.append(TravelData(placeData: datum, photoURL: <#T##String#>))
            
        }
        

    }

    func fetchPhoto(loactionid: String, completion: @escaping (Result<[PhotoDatum],Error>) -> Void) {
                
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

    func getPhoto(loactionid: String) {
        fetchPhoto(loactionid: loactionid) { result in
            switch result {
            case .success(let photoData):
//                self.tripAdvisorPhotoData.append(contentsOf: photoData)
//                print("self.tripAdvisorPhotoData:\(self.tripAdvisorPhotoData)")
//                for i in 0..<self.tripAdvisorPhotoData.count {
//                    self.travelData[i].photoURL = photoData[0].images.medium.url
//                }
                
                self.urlArr.append(photoData[0].images.medium.url)
                print(self.urlArr)
                
//                self.resultTableView.reloadData()
             

            case .failure(let error):
                
                print("photo~~failure~~")
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
        
        if let url = URL(string:"https://media-cdn.tripadvisor.com/media/photo-f/18/47/b1/1a/signature-beef-noodles.jpg") {
            cell.placeImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "default_Image"))
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
            cell.heartButton.backgroundColor = .systemBlue
        } else {
            cell.heartButton.isSelected = false
            cell.heartButton.backgroundColor = .systemYellow
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
        
        print("travelData[index]:\(travelData[index])")
        
        if placeSavedStatus == true {
            print("收藏")
        } else {
            print("退出")
        }
        
        resultTableView.reloadData()
    }
    
    
}
