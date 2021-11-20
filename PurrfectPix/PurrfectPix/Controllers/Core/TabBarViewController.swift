//
//  TabBarViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

    
        // 以下 apple ID sign in  第一次可以，第二次有誤
        guard let userID = AuthManager.shared.userID,
//              let username = AuthManager.shared.username,
              let email = AuthManager.shared.email
        else {
                  print("Create tab bar with user info error")
                  return
              }

        let currentUser = User(userID: userID, username: "", email: email, profilePic: "")

        // define VCs
        let home = HomeViewController()
        let explore = ExploreViewController()
        let camera = CameraViewController()
        let activity = NotificationsViewController()
        let profile = ProfileViewController(userID: userID)

        let nav1 = UINavigationController(rootViewController: home)
        let nav2 = UINavigationController(rootViewController: explore)
        let nav3 = UINavigationController(rootViewController: camera)
        let nav4 = UINavigationController(rootViewController: activity)
        let nav5 = UINavigationController(rootViewController: profile)

        nav1.navigationBar.tintColor = .P1
        nav2.navigationBar.tintColor = .P1
        nav3.navigationBar.tintColor = .P1
        nav4.navigationBar.tintColor = .P1
        nav5.navigationBar.tintColor = .P1

        if #available(iOS 14.0, *) {
            home.navigationItem.backButtonDisplayMode = .minimal
            explore.navigationItem.backButtonDisplayMode = .minimal
            camera.navigationItem.backButtonDisplayMode = .minimal
            activity.navigationItem.backButtonDisplayMode = .minimal
            profile.navigationItem.backButtonDisplayMode = .minimal
        } else {
            nav1.navigationItem.backButtonTitle = ""
            nav2.navigationItem.backButtonTitle = ""
            nav3.navigationItem.backButtonTitle = ""
            nav4.navigationItem.backButtonTitle = ""
            nav5.navigationItem.backButtonTitle = ""
        }

        // Define tab items
        nav1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1 )
        nav2.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "safari"), tag: 1 )
        nav3.tabBarItem = UITabBarItem(title: "Camera", image: UIImage(systemName: "camera"), tag: 1 )
        nav4.tabBarItem = UITabBarItem(title: "Notifications", image: UIImage(systemName: "bell"), tag: 1 )
        nav5.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), tag: 1 )
        self.tabBar.tintColor = .P2 // for all tab bar selected state

        // Set controllers
        self.setViewControllers([nav2, nav1, nav3, nav4, nav5], animated: false)

    }

}
