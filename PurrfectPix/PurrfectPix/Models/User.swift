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
    let profilePic: String?

    // community
    let followingUsers:[String]?
    let logInCount: Int?

}
