//
//  HomePost.swift
//  PurrfectPix
//
//  Created by Amber on 10/19/21.
//

import Foundation

enum HomeFeedCellType {
    // each of these type have their own ViewModels
    case poster(viewModel: PosterCollectionViewCellViewModel)
    case petTag(viewModel: PostPetTagCollectionViewCellViewModel)
    case post(viewModel: PostCollectionViewCellViewModel)
    case actions(viewModel: PostActionsCollectionViewCellViewModel)
    case likeCount(viewModel: PostLikesCollectionViewCellViewModel)
    case caption(viewModel: PostCaptionCollectionViewCellViewModel)
    case timestamp(viewModel: PostDatetimeCollectionViewCellViewModel)

}
