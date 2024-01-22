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
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(200)
            
        }

        contentView.addSubview(heartButton)
        heartButton.snp.makeConstraints { make in
            make.top.equalTo(placeImageView.snp.top).offset(10)
            make.trailing.equalTo(placeImageView.snp.trailing).offset(-10)
//            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        setupHeartButton()
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(placeImageView.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
        nameLabel.textColor = .black
        nameLabel.backgroundColor = .systemCyan
        nameLabel.textAlignment = .left
        nameLabel.font = UIFont.systemFont(ofSize: 18)
    }
    
    func setupHeartButton() {
        heartButton.backgroundColor = UIColor.init(white: 1, alpha: 1)
        heartButton.layer.cornerRadius = 10
        heartButton.layer.borderWidth = 1
        heartButton.layer.borderColor = UIColor.white.cgColor
        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        heartButton.setTitle("加入收藏", for: .normal)
        heartButton.setTitleColor(.black, for: [])
        heartButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        heartButton.setTitle("已收藏", for: .selected)
        heartButton.tintColor = .systemRed
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
