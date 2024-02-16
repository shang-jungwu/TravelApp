//
//  ScheduleConcourseTableViewCell.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/28.
//

import UIKit
import SnapKit

class ScheduleConcourseTableViewCell: UITableViewCell {
   
    lazy var placeImageView = UIImageView()
    lazy var infoStackView = UIStackView()
    lazy var scheduleTitleLabel = UILabel()
    lazy var dateRangeLabel = UILabel()

    let uiSettingUtility = UISettingUtility()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white

        setupUI()
        setupInfoStack()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupInfoStack() {
        infoStackView.axis = .vertical
        infoStackView.spacing = 5
        infoStackView.addArrangedSubview(scheduleTitleLabel)
        infoStackView.addArrangedSubview(dateRangeLabel)
        setupLabel()
    }

    func setupUI() {
        contentView.backgroundColor = .white
        contentView.addSubview(placeImageView)
        placeImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.width.equalTo(80)
            make.height.equalTo(80)
            make.bottom.equalToSuperview().offset(-10)
        }
        uiSettingUtility.setupImageView(sender: placeImageView, cornerRadius: 40)

        
        contentView.addSubview(infoStackView)
        infoStackView.snp.makeConstraints { make in
            make.centerY.equalTo(placeImageView.snp.centerY)
            make.leading.equalTo(placeImageView.snp.trailing).offset(20)
            make.trailing.equalToSuperview().offset(-40)
        }
//        contentView.addSubview(scheduleTitleLabel)
//        scheduleTitleLabel.snp.makeConstraints { make in
//            make.centerY.equalTo(placeImageView.snp.centerY)
//            make.leading.equalTo(placeImageView.snp.trailing).offset(10)
//            make.trailing.equalToSuperview().offset(-40)
//        }
       
//        nameLabel.backgroundColor = .systemCyan

    }


    func setupLabel() {
        uiSettingUtility.labelSettings(label: scheduleTitleLabel, fontSize: 18, fontWeight: .bold, color: .black, alignment: .left, numOfLines: 0)
        uiSettingUtility.labelSettings(label: dateRangeLabel, fontSize: 0, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 1)
        dateRangeLabel.text = "date range"
        dateRangeLabel.adjustsFontSizeToFitWidth = true
    }



    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
        // Configure the view for the selected state
    }
}
