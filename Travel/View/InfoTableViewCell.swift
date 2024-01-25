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
    
    lazy var nameAreaView = UIView()
    lazy var aliasLabel = UILabel()
//    lazy var nameLabel = UILabel()
    
    lazy var ratingView = UIView()
    lazy var priceLabel = UILabel()
    lazy var categoryLabel = UILabel()
    lazy var ratingImageView = UIImageView()
    lazy var reviewCountLabel = UILabel()
    lazy var yelpLogoButton = UIButton(type: .custom)

    lazy var otherInfoView = UIView()
    lazy var addressLabel = UILabel()
    lazy var phoneLabel = UILabel()
    
    lazy var heartButton = UIButton(type: .custom)

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
        infoStackView.distribution = .equalSpacing
        
        infoStackView.addArrangedSubview(nameAreaView)
        setupNameAreaView()
        infoStackView.addArrangedSubview(ratingView)
        setupRatingView()
        infoStackView.addArrangedSubview(otherInfoView)
        setupOtherInfoView()
    }
    
    func setupRatingView() {
        ratingView.backgroundColor = .systemMint
        ratingView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        ratingView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(categoryLabel.snp.trailing).offset(10)
        }
        ratingView.addSubview(ratingImageView)
        ratingImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(priceLabel.snp.trailing).offset(15)
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
        otherInfoView.backgroundColor = .systemYellow
        
        otherInfoView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()//.offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        otherInfoView.addSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            
        }
    }
    
    func setupNameAreaView() {
        nameAreaView.backgroundColor = .systemCyan
//        nameAreaView.addSubview(nameLabel)
//        nameLabel.snp.makeConstraints { make in
//            make.top.equalToSuperview()
//            make.leading.equalToSuperview()
//            make.trailing.equalToSuperview()
//        }
        nameAreaView.addSubview(aliasLabel)
        aliasLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()//.offset(3)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
      
    }
    

    
    func setupUI() {
        contentView.addSubview(infoStackView)
        infoStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview().offset(-10)
        }
        setupInfoStack()
        setupLabel()
       
       
        contentView.addSubview(heartButton)
        heartButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(heartButton.snp.width)
        }
        setupHeartButton()

    }
    
    func setupLabel() {
//        uiSettingUtility.labelSettings(label: nameLabel, fontSize: 24, fontWeight: .bold, color: .black, alignment: .left, numOfLines: 0)
//        nameLabel.clipsToBounds = true
        
        uiSettingUtility.labelSettings(label: aliasLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 0)
        aliasLabel.clipsToBounds = true
        
        uiSettingUtility.labelSettings(label: addressLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 0)
        addressLabel.clipsToBounds = true
        
        uiSettingUtility.labelSettings(label: phoneLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 0)
        
        uiSettingUtility.labelSettings(label: priceLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 1)
        
        uiSettingUtility.labelSettings(label: reviewCountLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 0)
        
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
    

}
