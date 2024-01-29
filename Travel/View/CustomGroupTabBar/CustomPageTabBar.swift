//
//  CustomPageTitle.swift
//  ChipK
//
//  Created by  cm0536 on 2018/8/8.
//  Copyright © 2018年 CMoney. All rights reserved.
//

import UIKit

/// 標籤列代理
public protocol CustomPageTabBarDelegate: AnyObject {
    
    /// 點擊標籤事件
    ///
    /// - Parameter index: index
    func clickTab(index: Int)
}

/// 標籤列
open class CustomPageTabBar: UIView, PageTabBar {
   
    /// 標籤列按鈕
    public var tabButtons: [UIButton] = []
    
    /// 標題
    public var tabNames: [String] = []
    
    /// 代理
    public weak var delegate: CustomPageTabBarDelegate? = nil
    
    public var tabBarHeight: CGFloat { frame.height }
    
    /// 已選的index
    private var selectedIndex = -1
    
    /// 用tabNames初始化
    public init(tabNames: [String]) {
        self.tabNames = tabNames

        super.init(frame: CGRect.zero)
        let frame = CGRect(x: 0, y: 0, width: getDefaultTabBarWidth(), height: getDefaultTabBarHeight())
        self.frame = frame
        
        initialTabButtons()
        initialSeprateLine()
    }
    
    /// 用frame跟tabNames跟type初始化
    public init(frame: CGRect, tabNames: [String]) {
        self.tabNames = tabNames
        
        super.init(frame: frame)
        
        initialTabButtons()
        initialSeprateLine()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func set(delegate: CustomPageTabBarDelegate) {
        self.delegate = delegate
    }
    
    /// 點擊標籤
    @objc
    open func clickTab(_ button: UIButton) {
        if let pageIndex = tabButtons.firstIndex(of: button) {
            delegate?.clickTab(index: pageIndex)
        }
    }
    
    /// 設定標題按鈕
    open func initialTabButtons() {
        for i in 0..<tabNames.count {
            let button = getButton(index: i)
            setUnselectButton(button: button)
            button.addTarget(self, action: #selector(clickTab), for: .touchUpInside)
            self.addSubview(button)
            tabButtons.append(button)
        }
    }
    
    /// 設定分隔線
    func initialSeprateLine() {
        self.addSubview(getSeperateLine())
    }
    
    /// 取得預設bar寬度
    open func getDefaultTabBarWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    /// 取得預設bar高度
    open func getDefaultTabBarHeight() -> CGFloat {
        return 28
    }
    
    /// 設定標籤列
    open func setSelectedTab(index: Int) {
        
        let buttonIndices = tabButtons.indices
        
        // safe check, if selectedIndex or index not exist, will lead crash

        if buttonIndices.contains(selectedIndex){
            let previousButton = tabButtons[selectedIndex]
            setUnselectButton(button: previousButton)
        }
        
        if buttonIndices.contains(index){
            let button = tabButtons[index]
            button.isSelected = true
            setSelectedButton(button: button)
        }
        
        selectedIndex = index
    }
    
    /// 設定已選按鈕
    open func setSelectedButton(button: UIButton) {
        button.backgroundColor = UIColor.init(rgb: 0x838383)
        button.setTitleColor(UIColor.init(rgb: 0xFFFFFF), for: .normal)
    }
    
    /// 設定非選按鈕
    open func setUnselectButton(button: UIButton) {
        button.backgroundColor = UIColor.init(rgb: 0x333333)
        button.setTitleColor(UIColor.init(rgb: 0x838383), for: .normal)
    }
    
    /// 取得按鈕樣式
    open func getButton(index: Int) -> UIButton {
        // 按鈕寬高設定
        let width = frame.width / (CGFloat)(tabNames.count)
        let height = frame.height - 1
        let button = UIButton(frame: CGRect(x: width*(CGFloat)(index) + 8, y: 0, width: width - 16, height: height))
        button.setTitle(tabNames[index], for: .normal)
        button.setTitleColor(UIColor.gray, for: .highlighted)
        return button
    }
    
    /// 取得分隔線樣式
    open func getSeperateLine() -> UIView {
        let view = UIView(frame: CGRect(x: 8, y: self.frame.height-1, width: self.frame.width - 16, height: 1))
        view.backgroundColor = UIColor.init(rgb: 0x979797)
        return view
    }
}
