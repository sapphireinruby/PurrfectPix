//
//  User.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import Foundation

struct User: Codable {

    var userID: String  // generate from firebase
    var username: String
    var email: String
    var profilePic: String?

    // community
    var following: [String]?
    var followers: [String]?
    var blocking: [String]?
    var logInCount: Int?

    init(
        
        username: String,
        email: String,
        profilePic: String?,
        logInCount: Int = 0
    )
    {
        self.userID = ""
        self.username = username
        self.email = email
        self.profilePic = profilePic
        self.following = []
        self.followers = []
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
