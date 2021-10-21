//
//  User.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import Foundation

struct User: Codable {

    let userID: String  // generate from firebase, for fake data, copy from document
    let username: String
    let email: String
//    let petTag: String?  放在post裡了
    let profilePic: String?

    // ** 要不要記名下有多少ＰＯＳＴ

    // community
    let followingUsers:[String]?
    let logInCount: Int?

}
