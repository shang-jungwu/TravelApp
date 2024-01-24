//
//  DetailTableViewCell.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/23.
//

import UIKit
import GoogleMaps

protocol DetailTableViewCellDelegate: AnyObject {
    func savePlaceDidTap(indexPath: IndexPath)
    func showMap(_ cell: DetailTableViewCell, indexPath: IndexPath)
}

class DetailTableViewCell: UITableViewCell {

    lazy var placeImageView = UIImageView()
    lazy var infoStack = UIStackView()
    lazy var nameLabel = UILabel()
    lazy var heartButton = UIButton(type: .custom)
    lazy var addressLabel = UILabel()
    lazy var phoneLabel = UILabel()

    lazy var fakeMapView = UIImageView()
    
    lazy var mapView = GMSMapView()
    private let uiSettingUtility = UISettingUtility()
    
    var delegate: DetailTableViewCellDelegate?
    var indexPath: IndexPath?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupStackView()
        setupUI()
        showMap()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupStackView() {
        infoStack.axis = .vertical
        infoStack.distribution = .fillEqually
        
        infoStack.addArrangedSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(-50)
        }
        
        infoStack.addArrangedSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
        
        infoStack.addArrangedSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
        
        setupLabel()
        setupHeartButton()

    }
    
    func setupUI() {
        contentView.addSubview(placeImageView)
        placeImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(200)
            make.bottom.equalToSuperview().offset(-10)
        }
        uiSettingUtility.setupImageView(sender: placeImageView, cornerRadius: 0)
      
        contentView.addSubview(infoStack)
        infoStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        contentView.addSubview(heartButton)
        heartButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(heartButton.snp.width)
        }
        
        contentView.addSubview(fakeMapView)
        fakeMapView.backgroundColor = .systemGray
        fakeMapView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(200)
            make.bottom.equalToSuperview().offset(-10)
        }
        fakeMapView.isHidden = true
        
        //設定好再addSubview，否則會顯示預設地圖
        contentView.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(200)
            make.bottom.equalToSuperview().offset(-10)
        }
        mapView.isHidden = true
       
    }
    
    func setupMapView(lat: Double, lon: Double, zoom: Float, title: String, snippet: String?) {
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: zoom)
        mapView = GMSMapView.init(options: options)

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        marker.title = title
        marker.snippet = snippet
        marker.map = mapView
        
//        //設定好再addSubview，否則會顯示預設地圖
//        contentView.addSubview(mapView)
//        mapView.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(10)
//            make.leading.equalToSuperview()
//            make.trailing.equalToSuperview()
//            make.height.equalTo(200)
//            make.bottom.equalToSuperview().offset(-10)
//        }
        
    }
    
    // MARK: - Yelp API already offers coordinates
//    func convertAddressToPlacemark(address: String, completion: @escaping (CLLocationCoordinate2D,Error?) -> Void) {
//        let geoCoder = CLGeocoder()
//        geoCoder.geocodeAddressString(address) { (placeMarks, error) in
//            if error == nil {
//                let placeMark = placeMarks?.first
//                if let location = placeMark?.location {
//                    completion(location.coordinate, nil)
//                    return
//                }
//            }
//            completion(kCLLocationCoordinate2DInvalid, error)
//        }
//    }
    
//    func getCoordinate(address: String, title: String, snippet: String?) {
//        convertAddressToPlacemark(address: address) { location, error in
//            if error == nil {
//                print("lat:", location.latitude, "lon:", location.longitude)
//                self.setupMapView(lat: location.latitude, lon: location.longitude, zoom: 16.0, title: title, snippet: snippet ?? "")
//                self.mapView.isHidden = false
//                self.fakeMapView.isHidden = true
//            } else {
//                print("Fail to get coordinates~~~", error ?? "")
//                print(address)
//                self.mapView.isHidden = true
//                self.fakeMapView.isHidden = false
//            }
//        }
//    }
    
    func setupLabel() {
        nameLabel.text = "name"
        uiSettingUtility.labelSettings(label: nameLabel, fontSize: 24, fontWeight: .bold, color: .black, alignment: .left, numOfLines: 0)
        
        addressLabel.text = "address"
        uiSettingUtility.labelSettings(label: addressLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 0)
        
        phoneLabel.text = "phone"
        uiSettingUtility.labelSettings(label: phoneLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 0)
    }
    
    
    func setupHeartButton() {
        uiSettingUtility.setupHeartButton(sender: heartButton)
        heartButton.addTarget(self, action: #selector(heartDidTap), for: .touchUpInside)
    }
    
    @objc private func heartDidTap() {
        print("heart did tap")
        guard let delegate = delegate, let indexPath = indexPath else { print("xxxRETURNxxx")
            return }
        delegate.savePlaceDidTap(indexPath: indexPath)
    }
    
    func showMap() {
        guard let delegate = delegate, let indexPath = indexPath else { return }
        delegate.showMap(self, indexPath: indexPath)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.selectionStyle = .none
        // Configure the view for the selected state
    }

}
