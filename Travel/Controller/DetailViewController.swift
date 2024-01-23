//
//  DetailViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/18.
//

import UIKit
import SnapKit
import GoogleMaps

class DetailViewController: UIViewController {

    enum ContentPart: Int, CaseIterable {
        case image = 0
        case info
        case map
    }
    
    lazy var detailTableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .grouped)
    


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNav()
        setupUI()
        setupLabel()
        setupHeartButton()
    }
    
    func setupNav() {
        self.navigationItem.title = "Detail"
    }

    func setupUI() {
        view.addSubview(placeImageView)
        placeImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        placeImageView.tintColor = .systemGray
        placeImageView.layer.borderWidth = 0.5
        placeImageView.layer.cornerRadius = 15
        placeImageView.layer.borderColor = UIColor.systemGray.cgColor
        placeImageView.contentMode = .scaleAspectFit

        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(placeImageView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        view.addSubview(heartButton)
        heartButton.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel.snp.centerY)
            make.trailing.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(heartButton.snp.width)
        }
        
        view.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        view.addSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
    
//        setupMapView()
//        view.addSubview(mapView)
//        mapView.snp.makeConstraints { make in
//            make.top.equalTo(phoneLabel.snp.bottom).offset(10)
//            make.leading.equalToSuperview()
//            make.trailing.equalToSuperview()
//            make.height.equalTo(200)
//        }
        
        view.addSubview(fakeMapView)
        fakeMapView.tintColor = .systemGray
        fakeMapView.layer.borderWidth = 0.5
        fakeMapView.layer.cornerRadius = 15
        fakeMapView.layer.borderColor = UIColor.systemGray.cgColor
        fakeMapView.contentMode = .scaleAspectFit
        fakeMapView.snp.makeConstraints { make in
            make.top.equalTo(phoneLabel.snp.bottom).offset(40)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
       
    }
    
    
    func setupTableView() {
        detailTableView.delegate = self
        detailTableView.dataSource = self
        
        
    }
    
    func setupMapView() {
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 12)
        mapView = GMSMapView.init(options: options)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
       
    }
    
    
    func convertAddressToLatLong(address: String) -> (CGFloat,CGFloat) {
        
        return(0,0)
    }
    
    func setupLabel() {
        nameLabel.text = "name"
        uiSettingUtility.labelSettings(label: nameLabel, fontSize: 24, fontWeight: .bold, color: .black, alignment: .left, numOfLines: 1)
        
        addressLabel.text = "address"
        uiSettingUtility.labelSettings(label: addressLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 0)
        
        phoneLabel.text = "phone"
        uiSettingUtility.labelSettings(label: phoneLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 1)
        
    }
    
    
    func setupHeartButton() {
        uiSettingUtility.setupHeartButton(sender: heartButton)
//        heartButton.isSelected = false // 要依照前一頁的Bool
        heartButton.addTarget(self, action: #selector(heartDidTap), for: .touchUpInside)
    }
    
    
    @objc private func heartDidTap() {
        print("heart did tap")
       
    }

}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        ContentPart.allCases.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}
