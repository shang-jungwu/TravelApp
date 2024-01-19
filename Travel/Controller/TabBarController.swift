//
//  TabBarController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/17.
//

import UIKit

class TabBarController: UITabBarController {

    lazy var searchVC = SearchViewController()
    lazy var profileVC = ProfileViewController()
    lazy var detailVC = DetailViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.standardAppearance.backgroundColor = .gray
        self.tabBar.tintColor = .black

        createTabBarItems()
    }
    

    func createTabBarItems() {
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 0)

        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person"))
        
        detailVC.tabBarItem = UITabBarItem(title: "Detail", image: UIImage(systemName: "globe.central.south.asia.fill"), tag: 2)

        let controllerArray = [
            UINavigationController(rootViewController: searchVC), 
            UINavigationController(rootViewController: profileVC),
            UINavigationController(rootViewController: detailVC),
        ]
        self.viewControllers = controllerArray
//        self.setViewControllers(controllerArray, animated: true)
        
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
