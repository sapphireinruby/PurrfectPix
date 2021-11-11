//
//  NotificationCellViewModels.swift
//  PurrfectPix
//
//  Created by Amber on 11/10/21.
//

import Foundation

struct LikeNotificationCellViewModel: Equatable {
    let fromUsername: String
    let profilePictureUrl: URL
    let postUrl: URL  // to open the post
    let date: String
}

struct FollowNotificationCellViewModel: Equatable {
    let fromUsername: String
    let profilePictureUrl: URL
    let isCurrentUserFollowing: Bool
    let date: String
}

struct CommentNotificationCellViewModel: Equatable {
    let fromUsername: String
    let profilePictureUrl: URL
    let postUrl: URL
    let date: String
}
