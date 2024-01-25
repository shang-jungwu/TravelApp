//
//  DetailViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/18.
//

import UIKit
import SnapKit
//import GoogleMaps
import CoreLocation

class DetailViewController: UIViewController {

    enum ContentPart: Int, CaseIterable {
        case image = 0
        case info
        case map
    }
    
    let uiSettingUtility = UISettingUtility()

    var placeInfoData = [TravelData]() // 整筆api data
    var dataIndex = 0 // 要顯示的資料 aka 前一頁被點擊的那筆
    
    lazy var detailTableView = UITableView(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNav()
        setupUI()
        setupTableView()
        
        
    }
    
    func setupNav() {
        self.navigationItem.title = "Detail"
    }

   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("placeInfo:",placeInfoData[dataIndex])
        detailTableView.reloadData()

    }

    
    
    func setupUI() {
        view.addSubview(detailTableView)
        detailTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
       
    }
    
    
    func setupTableView() {
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.register(PlaceImageTableViewCell.self, forCellReuseIdentifier: "PlaceImageTableViewCell")
        detailTableView.register(InfoTableViewCell.self, forCellReuseIdentifier: "InfoTableViewCell")
        detailTableView.register(MapViewTableViewCell.self, forCellReuseIdentifier: "MapViewTableViewCell")
    }
    
  

}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        guard placeInfoData.indices.contains(dataIndex) else { return UITableViewCell() }
        
        let contentPart = ContentPart.allCases[index]
        let placeInfo = placeInfoData[dataIndex] // 整個api資料被點到的那一格

        switch contentPart {
        case .image:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceImageTableViewCell", for: indexPath) as? PlaceImageTableViewCell else { return UITableViewCell() }
          
            if let url = URL(string: placeInfo.placeData.imageURL) {
                cell.placeImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "fork.knife"))
            }
            
            return cell
            
        case .info:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTableViewCell", for: indexPath) as? InfoTableViewCell else { return UITableViewCell() }
            
            // InfoTableViewCellDelegate
            cell.delegate = self
            cell.indexPath = indexPath
            /////////////////////////////////////
            
            cell.nameLabel.text = placeInfo.placeData.name
            cell.aliasLabel.text = placeInfo.placeData.alias
            let rating = placeInfo.placeData.rating.description.replacingOccurrences(of: ".", with: "")
            cell.ratingImageView.image = UIImage(named: "Review_Ribbon_small_16_\(rating)")
            if let price = placeInfo.placeData.price {
                cell.priceLabel.text = "\(price)"
            } else {
                cell.priceLabel.text = "Free"
            }
            if let reviewCount = placeInfo.placeData.reviewCount {
                cell.reviewCountLabel.text = "\(reviewCount) reviews on"
            }
            
            cell.categoryLabel.text = "\(placeInfo.placeData.categories[0].title)"
            let fullAddress = placeInfo.placeData.location.displayAddress.reduce("", +)
            cell.addressLabel.text = fullAddress
            cell.phoneLabel.text = placeInfo.placeData.displayPhone

            updateHeartButtonUI(cell, placeIsSaved: placeInfo.isSaved)
            
            return cell
            
        case .map:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewTableViewCell", for: indexPath) as? MapViewTableViewCell else { return UITableViewCell() }

            cell.setupMapView(lat: placeInfo.placeData.coordinates.latitude!, lon: placeInfo.placeData.coordinates.longitude!, zoom: 16.0, title: placeInfo.placeData.name, snippet: nil)
            
           return cell
        }
            


    }
    
    private func updateHeartButtonUI(_ cell: InfoTableViewCell, placeIsSaved: Bool) {
        if placeIsSaved {
            cell.heartButton.isSelected = true
            print("現在是收藏狀態")
        } else {
            cell.heartButton.isSelected = false
            print("未收藏")
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        let titleLabel = UILabel()
        uiSettingUtility.labelSettings(label: titleLabel, fontSize: 24, fontWeight: .black, color: .black, alignment: .left, numOfLines: 0)
        titleLabel.text = self.placeInfoData[self.dataIndex].placeData.name
        header.backgroundColor = .white
        header.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-50)
            make.bottom.equalToSuperview().offset(-10)
        }
        header.backgroundColor = .systemTeal
        return header
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        60
//    }


} // ex tableview end

extension DetailViewController: InfoTableViewCellDelegate {
    func viewOnYelp() {
        if let url = URL(string: placeInfoData[dataIndex].placeData.url) {
            UIApplication.shared.open(url)
        }
    }
    

    func savePlaceDidTap(indexPath: IndexPath) {
        let index = indexPath.row
        guard placeInfoData.indices.contains(index) else { return }
        
        var placeSavedStatus = placeInfoData[dataIndex].isSaved
        placeSavedStatus = !placeSavedStatus // toggle
        placeInfoData[dataIndex].isSaved = placeSavedStatus // 更新資料
    
        
        if placeSavedStatus == true {
            print("here收藏")
        } else {
            print("here退出")
        }
        
        print("placeInfoData[dataIndex]:\(placeInfoData[dataIndex])")
        
        detailTableView.reloadRows(at: [indexPath], with: .automatic)
        
    }
    
    
}
