//
//  DetailViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/18.
//

import UIKit
import SnapKit
import GoogleMaps
import CoreLocation

class DetailViewController: UIViewController {

    enum ContentPart: Int, CaseIterable {
        case image = 0
        case info = 1
        case map = 2
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
        print("placeInfo:",placeInfoData[dataIndex].placeData)
        
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
        detailTableView.register(DetailTableViewCell.self, forCellReuseIdentifier: "DetailTableViewCell")
        detailTableView.backgroundColor = .systemYellow
        
    }
    
  

}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as? DetailTableViewCell, placeInfoData.indices.contains(0) else { return UITableViewCell() }
        
        let placeInfo = placeInfoData[dataIndex] // 整個api資料被點到的那一格
        let contentPart = ContentPart.allCases[index]

        switch contentPart {
        case .image:
//            cell.fakeMapView.isHidden = true
            cell.placeImageView.isHidden = false
            cell.mapView.isHidden = true
            cell.infoStack.isHidden = true
            cell.heartButton.isHidden = true
            if let url = URL(string: placeInfo.placeData.imageURL) {
                cell.placeImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "fork.knife"))
            }
            
        case .info:
            // SearchResultTableViewCellDelegate
            cell.delegate = self
            cell.indexPath = indexPath
            /////////////////////////////////////
//            cell.fakeMapView.isHidden = true
            cell.placeImageView.isHidden = true
            cell.mapView.isHidden = true
            cell.infoStack.isHidden = false
            cell.heartButton.isHidden = false
            
            cell.nameLabel.text = placeInfo.placeData.name
            
            let fullAddress = placeInfo.placeData.location.displayAddress.reduce("", +)
            cell.addressLabel.text = fullAddress
            cell.phoneLabel.text = placeInfo.placeData.phone
            cell.heartButton.isSelected = placeInfo.isSaved

            updateHeartButtonUI(cell, placeIsSaved: placeInfo.isSaved)
            
        case .map:
//            cell.fakeMapView.isHidden = false
            cell.placeImageView.isHidden = true
            cell.mapView.isHidden = false
            cell.infoStack.isHidden = true
            cell.heartButton.isHidden = true
                      
        }
        
        cell.setupMapView(lat: placeInfo.placeData.coordinates.latitude, lon: placeInfo.placeData.coordinates.longitude, zoom: 16.0, title: placeInfo.placeData.name, snippet: nil)
        
        return cell
    }
    
    private func updateHeartButtonUI(_ cell: DetailTableViewCell, placeIsSaved: Bool) {
        if placeIsSaved {
            cell.heartButton.isSelected = true
        } else {
            cell.heartButton.isSelected = false
        }
    }

    private func reloadMap() {
        
    }

} // ex tableview end

extension DetailViewController: DetailTableViewCellDelegate {
    func showMap(_ cell: DetailTableViewCell, indexPath: IndexPath) {
        let index = indexPath.row
        let placeInfo = placeInfoData[dataIndex]
        if index == ContentPart.map.rawValue {
            cell.mapView.isHidden = false
//            cell.fakeMapView.isHidden = false
            self.detailTableView.reloadRows(at: [indexPath], with: .automatic)
                        
        } else {
            cell.mapView.isHidden = true
            self.detailTableView.reloadRows(at: [indexPath], with: .automatic)
                        
//            cell.fakeMapView.isHidden = true
        }
       
    }
    
    func savePlaceDidTap(indexPath: IndexPath) {
        let index = indexPath.row
        guard placeInfoData.indices.contains(index) else { return }
        
        var placeSavedStatus = placeInfoData[index].isSaved
        placeSavedStatus = !placeSavedStatus // toggle
        placeInfoData[index].isSaved = placeSavedStatus // 更新資料
    
        if placeSavedStatus == true {
            print("收藏")
        } else {
            print("退出")
        }
        detailTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
}
