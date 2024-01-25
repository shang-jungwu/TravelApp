//
//  DetailTableViewCell.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/23.
//

import UIKit

protocol DetailTableViewCellDelegate: AnyObject {
    func savePlaceDidTap(indexPath: IndexPath)
}

class DetailTableViewCell: UITableViewCell {

    lazy var placeImageView = UIImageView()
    lazy var infoStack = UIStackView()
    
    lazy var nameStackView = UIStackView()
    lazy var aliasLabel = UILabel()
    lazy var nameLabel = UILabel()
    
    lazy var ratingView = UIView()
//    lazy var ratingStackView = UIStackView()
    lazy var ratingImageView = UIImageView()
    lazy var yelpLogoButton = UIButton(type: .custom)
    lazy var blankView = UIView()
    
    lazy var priceLabel = UILabel()
    lazy var categoryLabel = UILabel()
    lazy var addressLabel = UILabel()
    lazy var phoneLabel = UILabel()
    
    lazy var heartButton = UIButton(type: .custom)

    private let uiSettingUtility = UISettingUtility()
    
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
    
    func setupRatingView() {
        ratingView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        ratingView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(categoryLabel.snp.trailing).offset(11)
        }
        ratingView.addSubview(ratingImageView)
        ratingImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(priceLabel.snp.trailing).offset(15)
            make.height.equalTo(30)
        }
        ratingImageView.contentMode = .scaleAspectFit
        ratingView.addSubview(yelpLogoButton)
        yelpLogoButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(ratingImageView.snp.trailing).offset(10)
            make.width.equalTo(60)
            make.height.equalTo(60)
            make.bottom.equalToSuperview()
        }
        yelpLogoButton.setImage(UIImage(named: "yelp_logo_cmyk"), for: [])
        yelpLogoButton.imageView?.contentMode = .scaleAspectFit
    }
    
    func setupStackView() {
        nameStackView.axis = .vertical
        nameStackView.distribution = .fill
        nameStackView.spacing = 3
        nameStackView.addArrangedSubview(nameLabel)
        nameStackView.addArrangedSubview(aliasLabel)
        nameStackView.addArrangedSubview(ratingView)
      
        infoStack.axis = .vertical
        infoStack.distribution = .equalSpacing
        

        infoStack.addArrangedSubview(nameStackView)
        setupRatingView()

        
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
        nameLabel.text = "名稱"
        uiSettingUtility.labelSettings(label: nameLabel, fontSize: 24, fontWeight: .bold, color: .black, alignment: .left, numOfLines: 0)
        
        aliasLabel.text = "別名"
        uiSettingUtility.labelSettings(label: aliasLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 0)
        
        addressLabel.text = "address"
        uiSettingUtility.labelSettings(label: addressLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 0)
        
        phoneLabel.text = "phone"
        uiSettingUtility.labelSettings(label: phoneLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 0)
        
        priceLabel.text = "price$$$$$"
        uiSettingUtility.labelSettings(label: priceLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 1)
        
        categoryLabel.text = "Category"
        uiSettingUtility.labelSettings(label: categoryLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 1)
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
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.selectionStyle = .none
    }

}
