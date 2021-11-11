//
//  AppDelegate.swift
//  PurrfectPix
//
//  Created by Amber on 10/16/21.
//

import Firebase
import FirebaseAuth
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // swiftlint:disable force_cast
    static let shared = UIApplication.shared.delegate as! AppDelegate
    // swiftlint:enable force_cast
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        if let user = Auth.auth().currentUser {
            print("You're sign in as \(user.uid), email: \(user.email ?? "")")
        }

        // 以下兩行會每次開app 先登出使用者登出

        do { try Auth.auth().signOut() }
        catch{
        }


//         Add fake data notification for current user
//        let id = NotificationsManager.newIdentifier()
//        let model = PurrNotification(identifier: id, notificationType: 1, profilePictureUrl: , fromUserID: <#T##String#>, fromUsername: "Amber", targetUserID: "Jr0VXFfmrmbeLeaAJwgEnbV5J5z1", dateString: "11/11/2021", postId: nil, postUrl: "https://img.technews.tw/wp-content/uploads/2021/09/08105820/Japanese-Scottish-Fold-Motimaru-grabs-Guinness-World-Record-for-most-watched-cat-on-YouTube.jpg", isFollowing: nil)
//        NotificationsManager.shared.create(notification: model, for: "Jr0VXFfmrmbeLeaAJwgEnbV5J5z1") // to user: shiba110

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}
