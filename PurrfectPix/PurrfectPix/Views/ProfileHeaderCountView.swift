//
//  File.swift
//  PurrfectPix
//
//  Created by Amber on 11/13/21.
//

import UIKit

protocol ProfileHeaderCountViewDelegate: AnyObject {
    func profileHeaderCountViewDidTapFollowers(_ containerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapFollowing(_ containerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapPosts(_ containerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapEditProfile(_ containerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapFollow(_ containerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapUnFollow(_ containerView: ProfileHeaderCountView)
}

class ProfileHeaderCountView: UIView {

    weak var delegate: ProfileHeaderCountViewDelegate?

    private var action = ProfileButtonType.edit

    // Count Buttons

    private let followerCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
    }()

    private let followingCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
    }()

    let postCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
    }()

    private let actionButton = PurrFollowButton()

    private var isFollowing = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(followerCountButton)
        addSubview(followingCountButton)
        addSubview(postCountButton)
        addSubview(actionButton)
        addActions()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func addActions() {
        followerCountButton.addTarget(self, action: #selector(didTapFollowers), for: .touchUpInside)
        followingCountButton.addTarget(self, action: #selector(didTapFollowing), for: .touchUpInside)
        postCountButton.addTarget(self, action: #selector(didTapPosts), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }

    // Actions

    @objc func didTapFollowers() {
        delegate?.profileHeaderCountViewDidTapFollowers(self)
    }

    @objc func didTapFollowing() {
        delegate?.profileHeaderCountViewDidTapFollowing(self)
    }

    @objc func didTapPosts() {
        delegate?.profileHeaderCountViewDidTapPosts(self)
    }

    @objc func didTapActionButton() {
        switch action {
        case.edit:
            delegate?.profileHeaderCountViewDidTapEditProfile(self)
        case .follow:
            if self.isFollowing {
                // unfollow
                delegate?.profileHeaderCountViewDidTapUnFollow(self)
            }
            else {
                // Follow
                delegate?.profileHeaderCountViewDidTapFollow(self)
            }
            self.isFollowing = !isFollowing
            actionButton.configure(for: isFollowing ? .unfollow : .follow)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonWidth: CGFloat = (width-12)/3

        followerCountButton.frame = CGRect(x: 4, y: 4, width: buttonWidth, height: height/2)
        followingCountButton.frame = CGRect(x: followerCountButton.right+4, y: 4, width: buttonWidth, height: height/2)
        postCountButton.frame = CGRect(x: followingCountButton.right+4, y: 4, width: buttonWidth, height: height/2)

        actionButton.frame = CGRect(x: 4, y: height-42, width: width-4, height: 40)
    }

    func configure(with viewModel: ProfileHeaderCountViewViewModel) {
        followerCountButton.setTitle("\(viewModel.followerCount)\nFollowers", for: .normal)
        followingCountButton.setTitle("\(viewModel.followingCount)\nFollowing", for: .normal)
        postCountButton.setTitle("\(viewModel.postsCount)\nPosts", for: .normal)

        self.action = viewModel.actionType

        switch viewModel.actionType {
        case .edit:
            actionButton.backgroundColor = .systemBackground
            actionButton.setTitle("Edit Profile", for: .normal)
            actionButton.setTitleColor(.label, for: .normal)
            actionButton.layer.borderWidth = 0.5
            actionButton.layer.borderColor = UIColor.tertiaryLabel.cgColor

        case .follow(let isFollowing):
            self.isFollowing = isFollowing
            actionButton.configure(for: isFollowing ? .unfollow : .follow)
        }
    }
}
