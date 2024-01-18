//
//  SearchResultTableViewCell.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/18.
//

import UIKit
import SnapKit

protocol SearchResultTableViewCellDelegate: AnyObject {
    
}

class SearchResultTableViewCell: UITableViewCell {

    
    lazy var backGroundImageView = UIImageView()
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
        contentView.addSubview(backGroundImageView)
        backGroundImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(200)
            
        }

        contentView.addSubview(heartButton)
        heartButton.snp.makeConstraints { make in
            make.top.equalTo(backGroundImageView.snp.top).offset(10)
            make.trailing.equalTo(backGroundImageView.snp.trailing).offset(-10)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        setupHeartButton()
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(backGroundImageView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
        nameLabel.textColor = .black
        nameLabel.backgroundColor = .systemCyan
        nameLabel.textAlignment = .left
        nameLabel.font = UIFont.systemFont(ofSize: 16)
    }
    
    func setupHeartButton() {
        heartButton.backgroundColor = .systemYellow
        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        heartButton.setImage(UIImage(systemName: "heart"), for: .selected)
        heartButton.tintColor = .systemGray
        heartButton.isSelected = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
