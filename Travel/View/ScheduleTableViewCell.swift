//
//  ScheduleTableViewCell.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/25.
//


import UIKit
import SnapKit

class ScheduleTableViewCell: UITableViewCell {
    
    lazy var placeImageView = UIImageView()
    lazy var nameLabel = UILabel()
    lazy var timeLabel = UILabel()
    
    let uiSettingUtility = UISettingUtility()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
//        self.accessoryType = .disclosureIndicator
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
        }
        uiSettingUtility.labelSettings(label: timeLabel, fontSize: 14, fontWeight: .regular, color: .black, alignment: .center, numOfLines: 1)
        timeLabel.text = "08:00"
        
        contentView.addSubview(placeImageView)
        placeImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(timeLabel.snp.trailing).offset(15)
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
