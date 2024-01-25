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
    lazy var favoriteVC = FavoriteViewController()
    lazy var scheduleVC = ScheduleViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.standardAppearance.backgroundColor = .gray
        self.tabBar.tintColor = .black

        createTabBarItems()
    }
    

    func createTabBarItems() {
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 0)

        favoriteVC.tabBarItem = UITabBarItem(title: "Favorite", image: UIImage(systemName: "heart.fill"), tag: 1)
        scheduleVC.tabBarItem = UITabBarItem(title: "Schedule", image: UIImage(systemName: "book"), tag: 2)
        
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person"))

        let controllerArray = [
            UINavigationController(rootViewController: searchVC),
            UINavigationController(rootViewController: favoriteVC),
            UINavigationController(rootViewController: scheduleVC),
            UINavigationController(rootViewController: profileVC),
           
        ]
        self.viewControllers = controllerArray
//        self.setViewControllers(controllerArray, animated: true)
        
    }
    
   

}
