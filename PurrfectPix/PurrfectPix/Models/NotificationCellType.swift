//
//  NotificationCellType.swift
//  PurrfectPix
//
//  Created by Amber on 11/10/21.
//

import Foundation

enum NotificationCellType {
    case follow(viewModel: FollowNotificationCellViewModel)
    case like(viewModel: LikeNotificationCellViewModel)
    case comment(viewModel: CommentNotificationCellViewModel)
}
