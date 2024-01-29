//
//  FavoriteListTableViewCell.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/25.
//

import UIKit

class FavoriteListTableViewCell: UITableViewCell {

    lazy var placeImageView = UIImageView()
    lazy var nameLabel = UILabel()
    lazy var heartButton = UIButton(type: .custom)
    
    let uiSettingUtility = UISettingUtility()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        self.accessoryType = .disclosureIndicator
//        contentView.layer.cornerRadius = 10
//        contentView.layer.borderColor = UIColor.green.cgColor
//        contentView.layer.borderWidth = 1
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(placeImageView)
        placeImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(15)
            make.width.equalTo(80)
            make.height.equalTo(80)
            make.bottom.equalToSuperview().offset(-10)
        }
        uiSettingUtility.setupImageView(sender: placeImageView, cornerRadius: 40)

        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(placeImageView.snp.centerY)
            make.leading.equalTo(placeImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-15)
        }
        uiSettingUtility.labelSettings(label: nameLabel, fontSize: 18, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 0)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}