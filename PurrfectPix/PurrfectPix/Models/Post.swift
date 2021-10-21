//
//  Post.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import Foundation

struct Post: Codable {

    let userID: String // 2 個都要 ** PostID or userID 是否要
    let caption: String
    let petTag: String // ** here or user?
    let postedDate: String  // date
    let postUrlString: String // storageURL for pic?
    let likers: [String]?
    let comments: [CommentByUser]? // map :  comment [ { user: String, comment: String }]

    // storageReference
    // create a reference with UserID

    let location: String?
}

struct CommentByUser: Codable {

    let user: String
    let comment: String
    
}
