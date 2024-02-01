//
//  ScheduleTableViewCell.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/25.
//


import UIKit
import SnapKit

protocol ScheduleTableViewCellDelegate: AnyObject {
    func timeChange(indexPath: IndexPath, time: Date)
}

class ScheduleTableViewCell: UITableViewCell {
    
    lazy var placeImageView = UIImageView()
    lazy var nameLabel = UILabel()
    lazy var timeLabel = UILabel()
    lazy var timePicker = UIDatePicker()
    
    let uiSettingUtility = UISettingUtility()
    
    var delegate: ScheduleTableViewCellDelegate?
    var indexPath: IndexPath?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        setupUI()
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTimePicker() {
        timePicker.preferredDatePickerStyle = .compact
        timePicker.datePickerMode = .time
//        timePicker.setContentCompressionResistancePriority(.required, for: .horizontal)
//        timePicker.setContentHuggingPriority(.required, for: .horizontal)
        
        timePicker.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        timePicker.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        timePicker.minuteInterval = 10
        
        timePicker.addTarget(self, action: #selector(timeChange), for: .valueChanged)

    }
    
    @objc private func timeChange() {
        guard let delegate = delegate, let indexPath = indexPath else {
            return
        }
        delegate.timeChange(indexPath: indexPath, time: timePicker.date)
    }
    
    func setupUI() {
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
        }

        contentView.addSubview(timePicker)
        timePicker.snp.makeConstraints { make in
            make.edges.equalTo(timeLabel)
            make.width.equalTo(100)
        }
        setupTimePicker()
        
       
        contentView.addSubview(placeImageView)
        placeImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalTo(timeLabel.snp.trailing).offset(15)
            make.width.equalTo(60)
            make.height.equalTo(60)
            make.bottom.equalToSuperview().offset(-20)
        }
        uiSettingUtility.setupImageView(sender: placeImageView, cornerRadius: 10)

        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(placeImageView.snp.centerY)
            make.leading.equalTo(placeImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        setupLabel()

    }
    

    
    func setupLabel() {
        uiSettingUtility.labelSettings(label: timeLabel, fontSize: 14, fontWeight: .regular, color: .clear, alignment: .center, numOfLines: 1)
        timeLabel.text = "08:00"
        // 防止 time label 被延展和壓縮
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        uiSettingUtility.labelSettings(label: nameLabel, fontSize: 18, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
