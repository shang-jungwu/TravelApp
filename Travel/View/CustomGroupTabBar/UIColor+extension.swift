//
//  UIColor+Extensions.swift
//  SwiftBackend
//
//  Created by  cm0536 on 2018/9/13.
//  Copyright © 2018年 CMoney. All rights reserved.
//

import UIKit

// MARK: - UIColor
public extension UIColor {
    
    /// 初始化
    ///
    /// - Parameters:
    ///   - red: 紅(0~255)
    ///   - green: 綠(0~255)
    ///   - blue: 藍(0~255)
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    
    /// 初始化
    ///
    /// - Parameters:
    ///   - r: 紅(0~255)
    ///   - g: 綠(0~255)
    ///   - b: 藍(0~255)
    ///   - a: 透明度(0~255)
    convenience init(r: Int, g: Int, b: Int, a: Float) {
        assert(r >= 0 && r <= 255, "Invalid red component")
        assert(g >= 0 && g <= 255, "Invalid green component")
        assert(b >= 0 && b <= 255, "Invalid blue component")
        assert(a >= 0 && a <= 255, "Invalid alpha component")
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a))
    }
    
    
    /// 初始化
    ///
    /// - Parameter rgb: 十六進位
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
