//
//  TabBarController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/17.
//

import UIKit

class TabBarController: UITabBarController {

    lazy var searchVC = SearchViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createTabBarItems()
    }
    

    func createTabBarItems() {
        self.tabBar.standardAppearance.backgroundColor = .gray
        self.tabBar.tintColor = .black
        
        searchVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "magnifyingglass"), tag: 0)
        
        let controllerArray = [
            UINavigationController(rootViewController: searchVC)
        ]
        self.viewControllers = controllerArray
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
