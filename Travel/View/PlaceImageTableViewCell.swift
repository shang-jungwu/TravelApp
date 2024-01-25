//
//  DetailTableViewCell.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/23.
//

import UIKit



class PlaceImageTableViewCell: UITableViewCell {

    lazy var placeImageView = UIImageView()
    
    private let uiSettingUtility = UISettingUtility()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(placeImageView)
        placeImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()//.offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(200)
            make.bottom.equalToSuperview()//.offset(-10)
        }
        uiSettingUtility.setupImageView(sender: placeImageView, cornerRadius: 0)
    
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.selectionStyle = .none
    }

}
