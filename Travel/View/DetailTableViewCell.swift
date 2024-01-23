//
//  DetailTableViewCell.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/23.
//

import UIKit
import GoogleMaps

protocol DetailTableViewCellDelegate: AnyObject {
    func placeWasSaved(indexPath: IndexPath)
}

class DetailTableViewCell: UITableViewCell {

    lazy var placeImageView = UIImageView()
    
    
    lazy var infoStack = UIStackView()
    lazy var nameLabel = UILabel()
    lazy var heartButton = UIButton(type: .custom)
    lazy var addressLabel = UILabel()
    lazy var phoneLabel = UILabel()
    
    
    lazy var fakeMapView = UIImageView()
    
    var mapView = GMSMapView()
    let uiSettingUtility = UISettingUtility()
    
    var delegate: DetailTableViewCellDelegate?
    var indexPath: IndexPath?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupStackView()
        setupUI()
       
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupStackView() {
        infoStack.axis = .vertical
        infoStack.distribution = .equalSpacing
        infoStack.spacing = 15
        
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
        placeImageView.tintColor = .systemGray
        placeImageView.layer.borderWidth = 0.5
        placeImageView.layer.borderColor = UIColor.systemGray.cgColor
        placeImageView.contentMode = .scaleAspectFit

      
        contentView.addSubview(infoStack)
        infoStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview().offset(-10)
            
        }
        infoStack.backgroundColor = .systemMint
        
        contentView.addSubview(heartButton)
        heartButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(heartButton.snp.width)
        }

//        setupMapView()
//        contentView.addSubview(mapView)
//        mapView.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(10)
//            make.leading.equalToSuperview()
//            make.trailing.equalToSuperview()
//            make.height.equalTo(200)
//            make.bottom.equalToSuperview().offset(-10)
//        }
        
        contentView.addSubview(fakeMapView)
        fakeMapView.tintColor = .systemGray
        fakeMapView.layer.borderWidth = 0.5
        fakeMapView.layer.borderColor = UIColor.systemGray.cgColor
        fakeMapView.contentMode = .scaleAspectFit
        fakeMapView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(200)
            make.bottom.equalToSuperview().offset(-10)
        }
        fakeMapView.isHidden = true
       
    }
    
    func setupMapView(lat: Double, lon: Double, zoom: Float, title: String, snippet: String) {
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: zoom)
        mapView = GMSMapView.init(options: options)

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        marker.title = title
        marker.snippet = snippet
        marker.map = mapView
        
        contentView.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(200)
            make.bottom.equalToSuperview().offset(-10)
        }
        mapView.isHidden = false

    }
    
    func convertAddressToCoordinates(address: String, completion: @escaping (CLLocationCoordinate2D,Error?) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placeMarks, error) in
            if error == nil {
                let placeMark = placeMarks?.first
                if let location = placeMark?.location {
                    completion(location.coordinate, nil)
                    return
                }
            }
            completion(kCLLocationCoordinate2DInvalid, error)
        }
    }
    
    func getCoordinate(address: String, title: String, snippet: String?) {
        convertAddressToCoordinates(address: address) { location, error in
            if error == nil {
                print("lat:", location.latitude, "lon:", location.longitude)
                self.setupMapView(lat: location.latitude, lon: location.longitude, zoom: 16.0, title: title, snippet: snippet ?? "")
                self.mapView.isHidden = false
                self.fakeMapView.isHidden = true
            } else {
                print("Fail to get coordinates~~~", error ?? "")
                print(address)
                self.mapView.isHidden = true
                self.fakeMapView.isHidden = false
            }
        }
    }
    
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
        delegate.placeWasSaved(indexPath: indexPath)
    }
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.selectionStyle = .none
        // Configure the view for the selected state
    }

}
