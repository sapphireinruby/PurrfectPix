//
//  Post.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import Foundation

struct Post: Codable {

    let userID: String
    var postID: String  // Image & the whole Post share one ID
    let caption: String
    let petTag: [String]
    let postedDate: String  // date
    var likers: [String]
    let comments: [CommentByUser]? // map :  comment [ { user: String, comment: String }]


    let postUrlString: String

    // storageReference: get the photo download URL from storage
    var storageReference: String? {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else { return nil }
        return "\(userID)/posts/\(postID).png" 
    }

    var date: Date {
        guard let date = DateFormatter.formatter.date(from: postedDate) else { fatalError() }
        return date
    }

    // 社群相關
    let location: String?

}

struct CommentByUser: Codable {

    let username: String
    let comment: String
    
}
