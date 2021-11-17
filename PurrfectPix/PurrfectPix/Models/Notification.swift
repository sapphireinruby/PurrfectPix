//
//  Notification.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import Foundation

struct PurrNotification: Codable {

    let identifier: String // ID
    let notificationType: Int // switch 1: like, 2: comment, 3: follow
    let profilePictureUrl: String
    let fromUserID: String
    let fromUsername: String // 需要嗎
    let targetUserID: String
    let dateString: String
    // Like/Comment:
    let postId: String?
    let postUrl: String?
    // Follow/Unfollow:
    let isFollowing: Bool?

}
