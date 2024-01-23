//
//  UISettingUtility.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/23.
//

import Foundation
import UIKit

struct UISettingUtility {
    
    func labelSettings(label: UILabel, fontSize: CGFloat, fontWeight: UIFont.Weight, color: UIColor, alignment: NSTextAlignment, numOfLines: Int) {
        label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        label.textColor = color
        label.textAlignment = alignment
        label.numberOfLines = numOfLines
    }
    
    func setupHeartButton(sender: UIButton) {
        sender.backgroundColor = UIColor.init(white: 1, alpha: 1)
        sender.layer.cornerRadius = 20
//        sender.layer.borderWidth = 1
//        sender.layer.borderColor = UIColor.white.cgColor
        sender.setImage(UIImage(systemName: "heart"), for: .normal)
//        sender.setTitle("加入收藏", for: .normal)
//        sender.setTitleColor(.black, for: [])
        sender.setImage(UIImage(systemName: "heart.fill"), for: .selected)
//        sender.setTitle("已收藏", for: .selected)
        sender.tintColor = .systemRed
//        sender.isSelected = false
        
    }
    
    
    
}
