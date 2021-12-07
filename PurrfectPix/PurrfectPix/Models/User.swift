//
//  User.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import Foundation

struct User: Codable {

    var userID: String  // the document ID generate from firebase
    var username: String
    var email: String
    var bio: String?
    var profilePic: String?

    // community
    var following: [String]?
    var followingCount: Int?
    var followers: [String]?
    var followerCount: Int?
    var postCount: Int?
    var blocking: [String]?
    var logInCount: Int?

    init(
        // 初始化會用到的參數
        userID: String,
        username: String,
        email: String,
        profilePic: String?,
        logInCount: Int = 0
    ){
        
        // 初始化會做的事情
        self.userID = userID
        self.username = username
        self.email = email
        self.bio = ""
        self.profilePic = profilePic
        self.following = []
        self.followingCount = 0
        self.followers = []
        self.followerCount = 0
        self.postCount = 0
        self.blocking = []
        self.logInCount = logInCount
    }

}

class CacheUserInfo {
    static let shared = CacheUserInfo()
    var cache = [String: User]() {
        didSet {
            print(cache)
        }
    }
}
