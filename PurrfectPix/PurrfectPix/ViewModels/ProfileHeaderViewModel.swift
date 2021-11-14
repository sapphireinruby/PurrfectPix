//
//   ProfileHeaderViewModel.swift
//  PurrfectPix
//
//  Created by Amber on 11/13/21.
//

import Foundation

    enum ProfileButtonType {
        case edit // for viewing self's profile
        case follow(isFollowing: Bool) // for others profile
    }

    struct ProfileHeaderViewModel {

        let profilePictureUrl: URL?
        let followerCount: Int
        let followingICount: Int
        let postCount: Int
        let buttonType: ProfileButtonType
        let username: String?
        let bio: String?

}
