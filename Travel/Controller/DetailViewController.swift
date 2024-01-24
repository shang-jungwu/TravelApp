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
        case info
        case map
    }
    
    let uiSettingUtility = UISettingUtility()
    
    var placeInfoData = [TravelData]()
    var dataIndex = 0
    
    lazy var detailTableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .grouped)
    

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
        print("placeInfoData[dataIndex]:",placeInfoData[dataIndex])
        detailTableView.reloadData()
//        print(placeInfoData)
    }
    
    
    func setupUI() {
        view.addSubview(detailTableView)
        detailTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
//        view.addSubview(placeImageView)
//        placeImageView.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
//            make.leading.equalToSuperview()
//            make.trailing.equalToSuperview()
//            make.height.equalTo(200)
//        }
//        placeImageView.tintColor = .systemGray
//        placeImageView.layer.borderWidth = 0.5
//        placeImageView.layer.cornerRadius = 15
//        placeImageView.layer.borderColor = UIColor.systemGray.cgColor
//        placeImageView.contentMode = .scaleAspectFit
//
//        view.addSubview(nameLabel)
//        nameLabel.snp.makeConstraints { make in
//            make.top.equalTo(placeImageView.snp.bottom).offset(20)
//            make.leading.equalToSuperview().offset(20)
//        }
//        
//        view.addSubview(heartButton)
//        heartButton.snp.makeConstraints { make in
//            make.centerY.equalTo(nameLabel.snp.centerY)
//            make.trailing.equalToSuperview()
//            make.width.equalTo(40)
//            make.height.equalTo(heartButton.snp.width)
//        }
//        
//        view.addSubview(addressLabel)
//        addressLabel.snp.makeConstraints { make in
//            make.top.equalTo(nameLabel.snp.bottom).offset(20)
//            make.leading.equalToSuperview().offset(20)
//        }
//        
//        view.addSubview(phoneLabel)
//        phoneLabel.snp.makeConstraints { make in
//            make.top.equalTo(addressLabel.snp.bottom).offset(20)
//            make.leading.equalToSuperview().offset(20)
//        }
        
    
//        setupMapView()
//        view.addSubview(mapView)
//        mapView.snp.makeConstraints { make in
//            make.top.equalTo(phoneLabel.snp.bottom).offset(10)
//            make.leading.equalToSuperview()
//            make.trailing.equalToSuperview()
//            make.height.equalTo(200)
//        }
        
//        view.addSubview(fakeMapView)
//        fakeMapView.tintColor = .systemGray
//        fakeMapView.layer.borderWidth = 0.5
//        fakeMapView.layer.cornerRadius = 15
//        fakeMapView.layer.borderColor = UIColor.systemGray.cgColor
//        fakeMapView.contentMode = .scaleAspectFit
//        fakeMapView.snp.makeConstraints { make in
//            make.top.equalTo(phoneLabel.snp.bottom).offset(40)
//            make.leading.equalToSuperview()
//            make.trailing.equalToSuperview()
//            make.height.equalTo(200)
//        }
       
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as? DetailTableViewCell, placeInfoData.indices.contains(0) else { return UITableViewCell() }
        
        let index = indexPath.row
        let contentPart = ContentPart.allCases[index]
        let placeInfo = placeInfoData[dataIndex]
        
        switch contentPart {
        case .image:
            cell.placeImageView.isHidden = false
            cell.fakeMapView.isHidden = true
            cell.mapView.isHidden = true
            cell.infoStack.isHidden = true
            cell.heartButton.isHidden = true
            cell.placeImageView.image = UIImage(systemName: "fork.knife")
            
        case .info:
            // SearchResultTableViewCellDelegate
            cell.delegate = self
            cell.indexPath = indexPath

            /////////////////////////////////////
            
            
            cell.placeImageView.isHidden = true
            cell.fakeMapView.isHidden = true
            cell.mapView.isHidden = true
            cell.infoStack.isHidden = false
            cell.heartButton.isHidden = false
            
            cell.nameLabel.text = placeInfo.placeData.name
            cell.addressLabel.text = placeInfo.placeData.addressObj.addressString
            cell.phoneLabel.text = "PhoneNum: Get With Location Details API"
            cell.heartButton.isSelected = placeInfo.isSaved
         
            updateHeartButtonUI(cell, placeIsSaved: placeInfo.isSaved)
            
        case .map:
            cell.placeImageView.isHidden = true
            cell.mapView.isHidden = false
            cell.infoStack.isHidden = true
            cell.heartButton.isHidden = true
            cell.fakeMapView.image = UIImage(systemName: "map")
           
            cell.getCoordinate(address: placeInfo.placeData.addressObj.addressString, title: placeInfo.placeData.name, snippet: nil)
        }
                
        return cell
    }
    
    private func updateHeartButtonUI(_ cell: DetailTableViewCell, placeIsSaved: Bool) {
        if placeIsSaved {
            cell.heartButton.isSelected = true
        } else {
            cell.heartButton.isSelected = false
        }
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = UIView()
//    
//        var nameLabel = UILabel()
//        var heartButton = UIButton(type: .system)
//        
//        header.addSubview(nameLabel)
//        nameLabel.snp.makeConstraints { make in
//            make.centerY.equalToSuperview()
//            make.leading.equalToSuperview().offset(20)
//        }
//        nameLabel.text = placeInfoData[section].placeData.name
//        
//        uiSettingUtility.labelSettings(label: nameLabel, fontSize: 25, fontWeight: .bold, color: .white, alignment: .left, numOfLines: 1)
//
//        header.addSubview(heartButton)
//        heartButton.snp.makeConstraints { make in
//            make.centerY.equalToSuperview()
//            make.trailing.equalToSuperview()
//            make.width.equalTo(40)
//            make.height.equalTo(heartButton.snp.width)
//        }
//        uiSettingUtility.setupHeartButton(sender: heartButton)
//        heartButton.isSelected = placeInfoData[section].isSaved
//        heartButton.addTarget(self, action: #selector(placeWasSaved), for: .touchUpInside)
//        header.backgroundColor = .systemBlue
//        return header
//    }


}

extension DetailViewController: DetailTableViewCellDelegate {
    func placeWasSaved(indexPath: IndexPath) {
        guard placeInfoData.indices.contains(0) else { return }
        
        var placeSavedStatus = placeInfoData[0].isSaved
        placeSavedStatus = !placeSavedStatus // toggle
        placeInfoData[0].isSaved = placeSavedStatus // 更新資料
    
        
        if placeSavedStatus == true {
            print("收藏")
        } else {
            print("退出")
        }
        
        detailTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
}
