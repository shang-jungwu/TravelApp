//
//  SearchResultTableViewCell.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/18.
//

import UIKit
import SnapKit

protocol SearchResultTableViewCellDelegate: AnyObject {
    func resultWasSaved(indexPath: IndexPath)
}

class SearchResultTableViewCell: UITableViewCell {

    let uiSettingUtility = UISettingUtility()
    weak var delegate: SearchResultTableViewCellDelegate?
    var indexPath: IndexPath?
    
    lazy var placeImageView = UIImageView()
    lazy var nameLabel = UILabel()
    lazy var heartButton = UIButton()
    
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
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview()//.offset(10)
            make.width.equalTo(80)
            make.height.equalTo(80)
            make.bottom.equalToSuperview().offset(-20)
        }
        placeImageView.tintColor = .systemGray
        
        contentView.addSubview(heartButton)
        heartButton.snp.makeConstraints { make in
            make.top.equalToSuperview()//.offset(10)
            make.trailing.equalToSuperview()//.offset(-10)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        setupHeartButton()
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(placeImageView.snp.centerY)
            make.leading.equalTo(placeImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview()
        }
        nameLabel.textColor = .black
        nameLabel.backgroundColor = .systemCyan
        nameLabel.textAlignment = .left
        nameLabel.font = UIFont.systemFont(ofSize: 18)
    }
    
    func setupHeartButton() {
        uiSettingUtility.setupHeartButton(sender: heartButton)
        heartButton.isSelected = false
        heartButton.addTarget(self, action: #selector(heartDidTap), for: .touchUpInside)
    }
    
    
    @objc private func heartDidTap() {
        print("heart did tap")
        guard let delegate = delegate, let indexPath = indexPath else { print("xxxRETURNxxx")
            return }
        delegate.resultWasSaved(indexPath: indexPath)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
