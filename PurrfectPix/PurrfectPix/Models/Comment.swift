//
//  Comment.swift
//  PurrfectPix
//
//  Created by Amber on 10/19/21.
//

import Foundation

struct Comment: Codable {

    let username: String // who left the comment
    let userID: String
    let comment: String
    let dateString: String
}
