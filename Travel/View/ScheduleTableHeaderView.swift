//
//  ScheduleTableHeaderView.swift
//  Travel
//
//  Created by 吳宗祐 on 2024/1/25.
//

import UIKit

class ScheduleTableHeaderView: UIView {

    let fullScreenWidth = UIScreen.main.bounds.width
    lazy var tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: fullScreenWidth, height: 200))

    lazy var imageView = UIImageView()
    lazy var schedultButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        addSubview(tableHeaderView)

        tableHeaderView.addSubview(schedultButton)
        schedultButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(100)
        }

        schedultButton.setTitle("schedule", for: [])
        schedultButton.backgroundColor = .systemCyan
        schedultButton.layer.cornerRadius = 50

//        tableHeaderView.addSubview(imageView)
//        imageView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//        imageView.image = UIImage(named: "default_Image")
//        imageView.contentMode = .scaleToFill

    }


}
