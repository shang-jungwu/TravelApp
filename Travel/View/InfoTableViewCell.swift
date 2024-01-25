//
//  InfoTableViewCell.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/25.
//

import UIKit

protocol InfoTableViewCellDelegate: AnyObject {
    func savePlaceDidTap(indexPath: IndexPath)
    func viewOnYelp()
}

class InfoTableViewCell: UITableViewCell {

    var delegate: InfoTableViewCellDelegate?
    var indexPath: IndexPath?
    var urlStr: String?
    
    lazy var infoStackView = UIStackView()
    
    lazy var aliasCategoryPriceView = UIView()
    lazy var aliasLabel = UILabel()
//    lazy var nameLabel = UILabel()
    
    lazy var ratingView = UIView()
    lazy var priceLabel = UILabel()
    lazy var categoryLabel = UILabel()
    lazy var ratingImageView = UIImageView()
    lazy var reviewCountLabel = UILabel()
    lazy var yelpLogoButton = UIButton(type: .custom)

    lazy var otherInfoView = UIView()
    lazy var pinImageView = UIImageView(image: UIImage(systemName: "mappin.and.ellipse"))
    lazy var addressLabel = UILabel()
    lazy var phoneImageView = UIImageView(image: UIImage(systemName: "phone"))
    lazy var phoneLabel = UILabel()
    
//    lazy var heartButton = UIButton(type: .custom)

    private let uiSettingUtility = UISettingUtility()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupInfoStack() {
        infoStackView.axis = .vertical
        infoStackView.distribution = .fill

//        infoStackView.backgroundColor = .systemCyan
        
        infoStackView.addArrangedSubview(aliasCategoryPriceView)
        setupAliasAreaView()
        infoStackView.addArrangedSubview(ratingView)
        setupRatingView()
        infoStackView.addArrangedSubview(otherInfoView)
        setupOtherInfoView()
    }
    
    func setupRatingView() {
//        ratingView.backgroundColor = .systemMint
      
        ratingView.addSubview(ratingImageView)
        ratingImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()//.offset(15)
            make.height.equalTo(30)
        }
        ratingImageView.contentMode = .scaleAspectFit
        
        ratingView.addSubview(reviewCountLabel)
        reviewCountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(ratingImageView.snp.trailing).offset(10)
        }
        
        ratingView.addSubview(yelpLogoButton)
        yelpLogoButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(reviewCountLabel.snp.trailing).offset(10)
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.bottom.equalToSuperview()
        }
        yelpLogoButton.setImage(UIImage(named: "yelp_logo_cmyk"), for: [])
        yelpLogoButton.imageView?.contentMode = .scaleAspectFit
        yelpLogoButton.addTarget(self, action: #selector(viewOnYelp), for: .touchUpInside)
    }
    
    @objc private func viewOnYelp() {
        print("view on yelp")
        guard let delegate = delegate else { return }
        delegate.viewOnYelp()
       
    }
    
    func setupOtherInfoView() {
//        otherInfoView.backgroundColor = .systemYellow
        otherInfoView.addSubview(pinImageView)
        pinImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()//.offset(10)
            make.leading.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        otherInfoView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(pinImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview()
        }
        
        
        otherInfoView.addSubview(phoneImageView)
        phoneImageView.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
        otherInfoView.addSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { make in
            make.top.equalTo(phoneImageView.snp.top)
            make.leading.equalTo(phoneImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            
        }
    }
    
    func setupAliasAreaView() {

        aliasCategoryPriceView.addSubview(aliasLabel)
        aliasLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        aliasCategoryPriceView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        aliasCategoryPriceView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(priceLabel.snp.leading).offset(-5)
        }
        
       
      
    }
    

    
    func setupUI() {
        contentView.addSubview(infoStackView)
        infoStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        }
        setupInfoStack()
        setupLabel()

    }
    
    func setupLabel() {
        
        uiSettingUtility.labelSettings(label: aliasLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 0)
        aliasLabel.clipsToBounds = true
        
        uiSettingUtility.labelSettings(label: addressLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 0)
        addressLabel.clipsToBounds = true
        
        uiSettingUtility.labelSettings(label: phoneLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 0)
        
        uiSettingUtility.labelSettings(label: priceLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 1)
        
        uiSettingUtility.labelSettings(label: reviewCountLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 0)
        
        uiSettingUtility.labelSettings(label: categoryLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 1)
    }
    
    
//    func setupHeartButton() {
//        uiSettingUtility.setupHeartButton(sender: heartButton)
//        heartButton.addTarget(self, action: #selector(heartDidTap), for: .touchUpInside)
//    }
//    
//    
//    @objc private func heartDidTap() {
//        print("heart did tap")
//        guard let delegate = delegate, let indexPath = indexPath else { print("xxxRETURNxxx")
//            return }
//        delegate.savePlaceDidTap(indexPath: indexPath)
//    }
    

}
