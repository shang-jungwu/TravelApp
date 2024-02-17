//
//  JourneyTableViewCell.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/25.
//


import UIKit
import SnapKit

protocol JourneyTableViewCellTableViewCellDelegate: AnyObject {
    func timeChange(indexPath: IndexPath, time: TimeInterval)
}

class JourneyTableViewCell: UITableViewCell {
    
    lazy var placeImageView = UIImageView()
    lazy var nameLabel = UILabel()
    lazy var timePicker = UIDatePicker()
    
    let uiSettingUtility = UISettingUtility()
    
    var delegate: JourneyTableViewCellTableViewCellDelegate?
    var indexPath: IndexPath?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

//        backgroundColor = .white

        setupUI()
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTimePicker() {
        timePicker.preferredDatePickerStyle = .compact
        timePicker.datePickerMode = .time
        
        timePicker.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        timePicker.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        timePicker.minuteInterval = 10
        
        timePicker.addTarget(self, action: #selector(timeChange), for: .valueChanged)

    }
    
    @objc private func timeChange() {
        guard let delegate = delegate, let indexPath = indexPath else {
            return
        }
        delegate.timeChange(indexPath: indexPath, time: timePicker.date.timeIntervalSince1970)
    }
    
    func setupUI() {
        contentView.backgroundColor = .white
        contentView.addSubview(timePicker)
        timePicker.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
        }
        setupTimePicker()
        
       
//        contentView.addSubview(placeImageView)
//        placeImageView.snp.makeConstraints { make in
//            make.top.equalTo(timePicker.snp.bottom).offset(10)
//            make.leading.equalTo(timePicker.snp.leading)
//            make.width.equalTo(80)
//            make.height.equalTo(80)
//            make.bottom.equalToSuperview().offset(-10)
//        }
//        uiSettingUtility.setupImageView(sender: placeImageView, cornerRadius: 10)
        

        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(timePicker.snp.bottom).offset(10)
            make.leading.equalTo(timePicker.snp.leading)
//            make.centerY.equalTo(placeImageView.snp.centerY)
//            make.leading.equalTo(placeImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-10)
        }

        uiSettingUtility.labelSettings(label: nameLabel, fontSize: 18, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 0)

    }
    

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .none
        // Configure the view for the selected state
    }


}
