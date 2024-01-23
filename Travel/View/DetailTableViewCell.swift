//
//  DetailTableViewCell.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/23.
//

import UIKit
import GoogleMaps

class DetailTableViewCell: UITableViewCell {

    lazy var placeImageView = UIImageView(image: UIImage(systemName: "fork.knife"))
    
    lazy var infoStack = UIStackView()
    lazy var nameLabel = UILabel()
    lazy var addressLabel = UILabel()
    lazy var phoneLabel = UILabel()
    lazy var heartButton = UIButton(type: .system)
    
    lazy var fakeMapView = UIImageView(image: UIImage(systemName: "map"))
    
    var mapView: GMSMapView!
    let uiSettingUtility = UISettingUtility()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupInfoStack()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupInfoStack() {
        infoStack.axis = .vertical
        infoStack.distribution = .equalSpacing
        infoStack.spacing = 15
        
        infoStack.addArrangedSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(placeImageView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        infoStack.addArrangedSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        infoStack.addArrangedSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
    }
    
    func setupUI() {
        contentView.addSubview(placeImageView)
        placeImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        placeImageView.tintColor = .systemGray
        placeImageView.layer.borderWidth = 0.5
        placeImageView.layer.cornerRadius = 15
        placeImageView.layer.borderColor = UIColor.systemGray.cgColor
        placeImageView.contentMode = .scaleAspectFit

      
        contentView.addSubview(infoStack)
        infoStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            
        }
        
        
        
        contentView.addSubview(heartButton)
        heartButton.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel.snp.centerY)
            make.trailing.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(heartButton.snp.width)
        }
        
    
        
    
//        setupMapView()
//        view.addSubview(mapView)
//        mapView.snp.makeConstraints { make in
//            make.top.equalTo(phoneLabel.snp.bottom).offset(10)
//            make.leading.equalToSuperview()
//            make.trailing.equalToSuperview()
//            make.height.equalTo(200)
//        }
        
        contentView.addSubview(fakeMapView)
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
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
