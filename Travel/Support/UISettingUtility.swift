//
//  UISettingUtility.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/23.
//

import Foundation
import UIKit
import MapKit
import SnapKit

struct UISettingUtility {
    
    func labelSettings(label: UILabel, fontSize: CGFloat, fontWeight: UIFont.Weight, color: UIColor, alignment: NSTextAlignment, numOfLines: Int) {
        label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        label.textColor = color
        label.textAlignment = alignment
        label.numberOfLines = numOfLines
    }
    
    func textFieldSetting(_ sender: TravelCustomTextField, placeholder: String, keyboard: UIKeyboardType, autoCapitalize: UITextAutocapitalizationType) {
        sender.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.systemGray])
        sender.layer.cornerRadius = 15
        sender.layer.borderWidth = 2
        sender.layer.borderColor = UIColor.white.cgColor
        sender.keyboardType = keyboard
        sender.autocapitalizationType = autoCapitalize
        sender.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
    
    func setupImageView(sender: UIImageView, cornerRadius: CGFloat) {
        sender.tintColor = .systemGray
        sender.layer.cornerRadius = cornerRadius
        sender.layer.borderWidth = 0.5
        sender.layer.borderColor = UIColor.systemGray.cgColor
        sender.contentMode = .scaleAspectFill
        sender.clipsToBounds = true
    }
    
    func setupHeartButton(sender: UIButton, backgroundColor: UIColor, borderColor: CGColor, borderWidth: CGFloat, cornerRadius: CGFloat) {
        sender.setImage(UIImage(systemName: "heart"), for: .normal)
        sender.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        sender.backgroundColor = backgroundColor
        sender.layer.borderColor = borderColor
        sender.layer.borderWidth = borderWidth
        sender.layer.cornerRadius = cornerRadius
        sender.tintColor = .systemOrange
    }
    
    
    
    
}


