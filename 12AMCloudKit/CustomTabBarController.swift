//
//  CustomTabBarController.swift
//  12AMCloudKit
//
//  Created by Nick Reichard on 6/20/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {

    class CustomTabBarController: UITabBarController {
        
        override func viewDidLoad() {
            super.viewDidLoad()
            customTabBar()
            self.tabBar.barTintColor = UIColor.green
        }
        
        func customTabBar() {
            let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
            let navigationController = storyboard1.instantiateViewController(withIdentifier: "feedTableViewController")
            navigationController.title = "Feed"
            navigationController.tabBarItem.image = #imageLiteral(resourceName: "homeIcon")
            
            let storyboard2 = UIStoryboard(name: "Main", bundle: nil)
            let searchTVC = storyboard2.instantiateViewController(withIdentifier: "searchTVC")
            let secondNavigationController = UINavigationController(rootViewController: searchTVC)
            secondNavigationController.title = "Search"
            secondNavigationController.tabBarItem.image = #imageLiteral(resourceName: "searchIcon")
            
            let storyboard3 = UIStoryboard(name: "Main", bundle: nil)
            let saveSearchTVC = storyboard3.instantiateViewController(withIdentifier: "")
            let thridNavigationController = UINavigationController(rootViewController: saveSearchTVC)
            thridNavigationController.title = "Saved"
            thridNavigationController.tabBarItem.image = #imageLiteral(resourceName: "globeIcon")
            
            // TODO: - add the cammera Tab bar
            //        let storyboard4 = UIStoryboard(name: "Main", bundle: nil)
            //        let cameraTVC = storyboard4.instantiateViewController(withIdentifier: "cameraTVC")
            //        let fourthNavigationController = UINavigationController(rootViewController: cameraTVC)
            //        fourthNavigationController.title = "Your Decade"
            //        fourthNavigationController.tabBarItem.image = #imageLiteral(resourceName: "plussButton")
            
            viewControllers = [navigationController, secondNavigationController, thridNavigationController]
            tabBar.isTranslucent = true
            
            let topBorder = CALayer()
            topBorder.frame = CGRect(x: 0, y: 0, width: 1000, height: 0.5)
            topBorder.backgroundColor = UIColor.rgb(229, green: 231, blue: 235).cgColor
            tabBar.layer.addSublayer(topBorder)
            tabBar.clipsToBounds = true
            
        }
    }

}
