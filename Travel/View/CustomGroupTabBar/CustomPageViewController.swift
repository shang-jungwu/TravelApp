//
//  CustomPageViewController.swift
//  ChipK
//
//  Created by  cm0536 on 2018/6/8.
//  Copyright © 2018年 CMoney. All rights reserved.
//

import UIKit

public protocol PageTabBar: UIView {
    
    var tabBarHeight: CGFloat {get}
    
    func set(delegate: CustomPageTabBarDelegate)
    
    func setSelectedTab(index: Int)
    
}

/// 自定義PageViewController
open class CustomPageViewController: UIViewController {
    
    /// 標籤列
    fileprivate var tabBar: PageTabBar
    
    /// 頁面
    private(set) public var viewControllers: [UIViewController]
    
    /// 頁面控制器
    fileprivate var pageViewController = UIPageViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    /// 現在的index
    public fileprivate(set) var currentIndex = -1
    
    /// 客製化pageVC與上方的距離
    private var customTopInterval: CGFloat?
    
    /// 要跳轉的index
    public var nextIndex = 0
    
    /// 切換index要做的事情
    public var onIndexChanged: ((Int)->Void)? = nil
    
    /// index改變 (原index: Int, 新index: Int)
    public var indexChanged: ((Int, Int) -> ())? = nil
    
    /// 代理
    public weak var delegate: CustomPageTabBarDelegate? = nil
    
    /// 是否可滑動
    public var isSwipeable: Bool = true {
        willSet {
            pageViewController.view.subviews.forEach{
                if let scroll = $0 as? UIScrollView {
                    scroll.isScrollEnabled = newValue
                }
            }
        }
    }
    
    public init(tabBar: PageTabBar, viewControllers: [UIViewController], customTopInterval: CGFloat? = nil) {
        self.customTopInterval = customTopInterval
        self.tabBar = tabBar
        self.viewControllers = viewControllers
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景顏色設定
        self.view.backgroundColor = .black//UIColor.init(rgb: 0x292929)
        
        tabBar.set(delegate: self)
        self.view.addSubview(tabBar)
        let topInterval = customTopInterval ?? tabBar.tabBarHeight
        
        // 下方內容頁
        pageViewController.dataSource = isSwipeable ? self : nil
        pageViewController.delegate = self
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.didMove(toParent: self)
        self.view.addSubview(pageViewController.view)
        self.addChild(pageViewController)
        
        if #available(iOS 11.0, *) {
            pageViewController.view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            pageViewController.view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            pageViewController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: topInterval).isActive = true
            pageViewController.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            pageViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            pageViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            pageViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: topInterval).isActive = true
            pageViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setViewController(index: nextIndex)
    }
    
    public func resetViewControllers(viewControllers: [UIViewController], nextIndex: Int) {
        let oIndex = currentIndex
        currentIndex = -1
        DispatchQueue.main.async {
            self.indexChanged?(oIndex, self.currentIndex)
            self.onIndexChanged?(self.currentIndex)
        }
        self.viewControllers = viewControllers
        setViewController(index: nextIndex)
    }
    
    /// 重新設定pageViewController的位置
    public func resetPageViewControllerLayout(customTopInterval: CGFloat? = nil){
        let topInterval = customTopInterval ?? tabBar.tabBarHeight
        pageViewController.view.frame = CGRect.init(x: 0, y: topInterval, width: self.view.bounds.width, height: self.view.bounds.height - topInterval)
        pageViewController.view.layoutIfNeeded()
    }
    
    /// 設定現在頁面
    func setViewController(index: Int) {
        setViewController(index: index, completion: nil)
    }
    
    /// 設定現在頁面
    public func setViewController(index: Int, callDelegate: Bool = true, completion: ((Bool)->Void)?) {
        
        //位置相同不做事
        guard index != currentIndex || index == -1 else {
            completion?(false)
            return
        }
        
        //嘗試找出指定位置的VC，如果沒有則找出指定位置為0的VC，還是沒有則強迫跳出
        let viewcontrollesIndices = viewControllers.indices
        if viewcontrollesIndices.contains(index){
            nextIndex = index
        } else {
            if viewcontrollesIndices.contains(0){
                nextIndex = 0
            } else {
                completion?(false)
                return
            }
        }
        
        pageViewController.view.isUserInteractionEnabled = false
        tabBar.setSelectedTab(index: nextIndex)
        let newController = viewControllers[nextIndex]
        let isAnimated = (newController != pageViewController.viewControllers?.first)
        
        pageViewController.setViewControllers([viewControllers[nextIndex]], direction: (nextIndex>currentIndex) ? .forward : .reverse, animated: isAnimated){
            complete in
            self.pageViewController.view.isUserInteractionEnabled = true
            let oIndex = self.currentIndex
            if complete {
                self.currentIndex = self.nextIndex
            } else {
                self.currentIndex = index
            }
            if callDelegate == true {
                DispatchQueue.main.async {
                    self.indexChanged?(oIndex, self.currentIndex)
                    self.onIndexChanged?(self.currentIndex)
                }
            }
            self.tabBar.setSelectedTab(index: self.nextIndex)
            if callDelegate == true {
                self.delegate?.clickTab(index: self.currentIndex)
            }
            completion?(complete)
        }
    }
    
}

// MARK: - CustomPageTabBarDelegate
extension CustomPageViewController: CustomPageTabBarDelegate {
    // 點擊標籤列
    public func clickTab(index: Int) {
        setViewController(index: index, completion: nil)
    }
}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension CustomPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pageIndex = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = pageIndex + 1
        guard viewControllers.indices.contains(nextIndex) else {
            return nil
        }
        return viewControllers[nextIndex]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pageIndex = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = pageIndex - 1
        guard viewControllers.indices.contains(nextIndex) else {
            return nil
        }
        return viewControllers[nextIndex]
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let pendingFirstVC = pendingViewControllers.first,
           let pendingFirstVCIndex = viewControllers.firstIndex(of: pendingFirstVC) {
            nextIndex = pendingFirstVCIndex
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let allPageVC = pageViewController.viewControllers,
           let pageFirstVC = allPageVC.first,
           let pageFirstVCIndex = viewControllers.firstIndex(of: pageFirstVC) {
            let oIndex = self.currentIndex
            currentIndex = pageFirstVCIndex
            DispatchQueue.main.async {
                self.indexChanged?(oIndex, self.currentIndex)
                self.onIndexChanged?(self.currentIndex)
            }
            nextIndex = currentIndex
            tabBar.setSelectedTab(index: currentIndex)
            self.delegate?.clickTab(index: self.currentIndex)
        }
    }
}

// MARK: - 畫面旋轉時用需的方法
extension CustomPageViewController {
    open func setTabBarHeight(height: CGFloat) {
        tabBar.frame.size.height = height
        pageViewController.view.frame = CGRect.init(x: 0, y: height, width: self.view.bounds.width, height: self.view.bounds.height - height)
        pageViewController.view.layoutIfNeeded()
    }
}
