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

        sender.setImage(UIImage(systemName: "heart"), for: .normal)
        sender.setImage(UIImage(systemName: "heart.fill"), for: .selected)

        sender.tintColor = .systemOrange
        
    }
    
    
    
}
