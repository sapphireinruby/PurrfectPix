//
//  User.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import Foundation

struct User: Codable {

    let userID: String  // generate from firebase
    let username: String
    let email: String
    let profilePic: String?

    // community
    let following: [String]?
    let followers: [String]?
    let blocking: [String]?
    let logInCount: Int?

    // init
}
