//
//  ScheduleTableHeaderView.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/25.
//

import UIKit

class ScheduleTableHeaderView: UIView {

    let fullScreenWidth = UIScreen.main.bounds.width
    lazy var tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: fullScreenWidth, height: 120))

    lazy var userImageView = UIImageView()
    lazy var countStack = UIStackView()
    lazy var countLabel = UILabel()
    lazy var countTitleLabel = UILabel()
    lazy var editButton = UIButton(type: .custom)

    lazy var scheduleInfoStack = UIStackView()
    lazy var scheduleTitleLabel = UILabel()
    lazy var destinationLabel = UILabel()
    lazy var departureDayLabel = UILabel()
    lazy var numberOfDaysLabel = UILabel()

    let uiSettingUtility = UISettingUtility()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        addSubview(tableHeaderView)

        tableHeaderView.addSubview(userImageView)
        userImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        uiSettingUtility.setupImageView(sender: userImageView, cornerRadius: 40)

        tableHeaderView.addSubview(countStack)
        countStack.snp.makeConstraints { make in
            make.centerY.equalTo(userImageView)
            make.leading.equalTo(userImageView.snp.trailing).offset(30)

        }
        setupConcourseStackView()

        tableHeaderView.addSubview(scheduleInfoStack)
        scheduleInfoStack.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
        }
        setupScheduleInfoStackView()
        
        tableHeaderView.addSubview(editButton)
        editButton.snp.makeConstraints { make in
            make.top.equalToSuperview()//.offset(10)
            make.trailing.equalToSuperview()//.offset(-10)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        setupEditButton()

    }

    func setupConcourseStackView() {
        countStack.axis = .vertical
        countStack.spacing = 5
        countStack.addArrangedSubview(countLabel)
        countStack.addArrangedSubview(countTitleLabel)
        setupLabel()
    }

    func setupScheduleInfoStackView() {
        scheduleInfoStack.axis = .vertical
//        scheduleInfoStack.spacing = 15

        scheduleInfoStack.addArrangedSubview(scheduleTitleLabel)
        scheduleInfoStack.addArrangedSubview(destinationLabel)
        scheduleInfoStack.addArrangedSubview(departureDayLabel)
        scheduleInfoStack.addArrangedSubview(numberOfDaysLabel)
        setupLabel()
    }
    
    func setupEditButton() {
        editButton.setImage(UIImage(systemName: "pencil"), for: [])
        editButton.tintColor = .black
      
    }
    
   



    func setupLabel() {
        // concourse
        uiSettingUtility.labelSettings(label: countLabel, fontSize: 16, fontWeight: .semibold, color: .black, alignment: .center, numOfLines: 1)
        uiSettingUtility.labelSettings(label: countTitleLabel, fontSize: 14, fontWeight: .regular, color: .systemGray, alignment: .center, numOfLines: 1)
        countTitleLabel.text = "行程"

        // schedule info
        uiSettingUtility.labelSettings(label: scheduleTitleLabel, fontSize: 20, fontWeight: .black, color: .black, alignment: .left, numOfLines: 0)
        scheduleTitleLabel.text = "Title"
        uiSettingUtility.labelSettings(label: destinationLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 0)
        destinationLabel.text = "Destination"
        uiSettingUtility.labelSettings(label: departureDayLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 1)
        departureDayLabel.text = "DepartureDay"
        uiSettingUtility.labelSettings(label: numberOfDaysLabel, fontSize: 16, fontWeight: .regular, color: .black, alignment: .left, numOfLines: 1)
        numberOfDaysLabel.text = "1"


    }



}
