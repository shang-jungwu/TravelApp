//
//  SearchResultViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/18.
//

import UIKit
import SnapKit
import SDWebImage
import GooglePlaces

class SearchResultViewController: UIViewController {
    
//    var searchResult = [Result]()
//    var photos = [UIImage]()
    
    var tripAdvisorPlaceData = [Datum]()
    var travelData = [TravelData]()
    
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
        
        resultTableView.reloadData()
    }
    
//    func foo(completion: @escaping ((Swift.Result<Data, Error>) -> Void)) {
//        
//        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(UInt(GMSPlaceField.photos.rawValue)))
//
//        placesClient?.fetchPlace(fromPlaceID: "foo",
//                                 placeFields: fields,
//                                 sessionToken: nil, callback: {
//          (place: GMSPlace?, error: Error?) in
//          if let error = error {
//            print("An error occurred: \(error.localizedDescription)")
//            return
//          }
//          if let place = place {
//            // Get the metadata for the first photo in the place photo metadata list.
//            let photoMetadata: GMSPlacePhotoMetadata = place.photos![0]
//
//            // Call loadPlacePhoto to display the bitmap and attribution.
//              self.placesClient?.loadPlacePhoto(photoMetadata, callback: { [self] (photo, error) -> Void in
//              if let error = error {
//                // TODO: Handle the error.
//                print("Error loading photo metadata: \(error.localizedDescription)")
//                  
//                  completion(.failure(error))
//                return
//              } else {
//                // Display the first image and its attributions.
//                  self.photos.append(photo!)
//                  print("photos.count:",photos.count)
//                  
//                  let imageData: Data = photo?.pngData() ?? Data()
//                  completion(.success(imageData))
//              }
//            })
//          }
//        })
//    }
    
//    func getIPlace() {
//        foo { result in
//            switch result {
//            case .success(let data):
//                break
//            case .failure(let error):
//                break
//            }
//        }
//    }
    

 

}

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        travelData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        guard travelData.indices.contains(index), let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableViewCell", for: indexPath) as? SearchResultTableViewCell else { return UITableViewCell() }
        
//        cell.backGroundImageView.image = photos[index]
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
