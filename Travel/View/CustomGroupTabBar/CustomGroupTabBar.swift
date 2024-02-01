//
//  CustomGroupTabBar.swift
//  SwiftBackend
//
//  Created by  cm0536 on 2018/9/13.
//  Copyright © 2018年 CMoney. All rights reserved.
//

import UIKit
import SnapKit


/// 自選股用的TabBar
public class CustomGroupTabBar: CustomPageTabBar {

    
    /// 風格物件
    private var style = CMCustomGroupTabBarStyle()
    
    /// 選擇線
    private lazy var selectedLine = { () -> UIView in
        let view = UIView()
        view.backgroundColor = style.selectedLineColor
        return view
    }()
    
    private lazy var scrollBar: UIScrollView = {
        let bar = UIScrollView(frame: self.bounds)
        bar.showsHorizontalScrollIndicator = false
        bar.showsHorizontalScrollIndicator = false
        bar.bounces = true
        addSubview(bar)
        
        return bar
    }()
    

    
    /// 用tabNames和風格物件初始化
    public init(tabNames: [String], style: CMCustomGroupTabBarStyle = CMCustomGroupTabBarStyle()) {
        self.style = style
        super.init(tabNames: tabNames)
        backgroundColor = style.backgroundColor
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initialSeprateLine() {
    }
    
    public override func initialTabButtons() {
        scrollBar.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        var x: CGFloat = 0
        if let leadingConstant = style.scrollViewLeadingConstant {
            x = leadingConstant
        }
        
        for name in tabNames {
            let button = UIButton()
            // 自己加的客製化條件
            button.layer.cornerRadius = 5
            /////
            button.setTitle(name, for: .normal)
            
            if let customFont = style.customSegmentButtonFont {
                button.titleLabel?.font = customFont
            }
            button.sizeToFit()
            button.frame.origin.x = x
            button.frame.size.height = getDefaultTabBarHeight()
            
            if let space = style.segmentSpace {
                x += button.frame.size.width + space
            } else {
                button.frame.size.width += 20
                x += button.frame.size.width
            }
            
            setUnselectButton(button: button)
            button.addTarget(self, action: #selector(clickTab(_:)), for: .touchUpInside)
            tabButtons.append(button)
            scrollBar.addSubview(button)
        }
        
        scrollBar.contentSize = CGSize(width: max(x, scrollBar.frame.width), height: getDefaultTabBarHeight())
        

    }
    
    public override func clickTab(_ button: UIButton) {
        super.clickTab(button)
        
        setSelectedTabCenter(button)
    }
    
    public override func setSelectedTab(index: Int) {
        super.setSelectedTab(index: index)
        
        // check index exist, otherwise will lead crash
        if tabButtons.indices.contains(index) == false {
            return
        }
        
        let tabButton = tabButtons[index]
        setSelectedTabCenter(tabButton)
    }
    
    public override func getDefaultTabBarWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    public override func getDefaultTabBarHeight() -> CGFloat {
        return style.tabBarHeight
    }
    
    public override func setSelectedButton(button: UIButton) {
        selectedLine.removeFromSuperview()
        
        // 底線顯示有問題
//       selectedLine.frame = CGRect(x: 0, y: self.frame.maxY - 3, width: button.frame.width, height: style.selectedLineHeight)

        // 以下兩種可以
        selectedLine.frame = CGRect(x: 0, y: button.frame.maxY - 4, width: button.frame.width, height: style.selectedLineHeight)
//        selectedLine.frame = CGRect(x: 0, y: self.bounds.maxY - 4, width: button.bounds.width, height: style.selectedLineHeight)
        ///////
        
        button.setTitleColor(style.selectedTabTextColor, for: .normal)
        button.backgroundColor = style.selectedTabColor
        button.addSubview(selectedLine)
        selectedLine.clipsToBounds = true

    }
    
    public override func setUnselectButton(button: UIButton) {
        button.setTitleColor(style.unselectedTabTextColor, for: .normal)
        button.backgroundColor = style.unselectedTabColor

    }
    
    // 使被選到的置中
    private func setSelectedTabCenter(_ button: UIButton) {
        let offsetX = max(0, min(button.center.x - (scrollBar.frame.width/2), scrollBar.contentSize.width - scrollBar.frame.width))
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
            self.scrollBar.contentOffset = CGPoint(x: offsetX, y: button.frame.origin.y)
        }, completion: nil)
    }
}

/// 自選股用的TabBar風格
public class CMCustomGroupTabBarStyle{
    
    /// 背景顏色
    public var backgroundColor = UIColor.clear
    
    /// 選擇線顏色
    public var selectedLineColor = UIColor.systemRed// #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    /// 被選中的分頁顏色
    public var selectedTabColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)//#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    
    /// 被選中的分頁文字顏色
    public var selectedTabTextColor = UIColor.black// #colorLiteral(red: 0.662745098, green: 0.662745098, blue: 0.662745098, alpha: 1)
    
    /// 未選中的分頁顏色
    public var unselectedTabColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)// #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    
    /// 未選中的分頁文字顏色
    public var unselectedTabTextColor = #colorLiteral(red: 0.662745098, green: 0.662745098, blue: 0.662745098, alpha: 1)
    
    /// 頁籤高度
    public var tabBarHeight: CGFloat = 44
        
    /// 頁籤字體
    public var customSegmentButtonFont: UIFont? = nil
    
    /// 底線高度(已選取)
    public var selectedLineHeight: CGFloat = 3
    
    /// 頁籤之間的間距
    public var segmentSpace: CGFloat? = nil
    
    /// scrollView 的 Leading 間距
    public var scrollViewLeadingConstant: CGFloat? = 20
    
    /// scrollView 的 trailing 間距
    public var scrollViewTrailingConstant: CGFloat? = 0
    
    /// 初始化
    public init() {
    }
}

