//
//  ProfileHeaderCollectionReusableView.swift
//  PurrfectPix
//
//  Created by Amber on 11/13/21.
//

import UIKit

class ProfileHeaderCollectionReusableView: UICollectionReusableView {

    static let identifier = "ProfileHeaderCollectionReusableView"

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()


    public let countContainerView = ProfileHeaderCountView()

    private let bioLabel: UILabel = {
//        guard let username = AuthManager.shared.username else {return }
        let label = UILabel()
        label.numberOfLines = 0 // line wrapping
        label.text = "\nThis is my profile bio!"
        label.font = .systemFont(ofSize: 18)
        return label
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        // header count
        addSubview(countContainerView)
        addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = width/3.5
        imageView.frame = CGRect(x: 4, y: 4, width: imageSize, height: imageSize)
        imageView.layer.cornerRadius = imageSize/2
        countContainerView.frame = CGRect(
            x: imageView.right+4,
            y: 3,
            width: width-imageView.right-8,
            height: imageSize
        )
        let bioSize = bioLabel.sizeThatFits(
            bounds.size
        )
        bioLabel.frame = CGRect(
            x: 4,
            y: imageView.bottom+8,
            width: width-8,
            height: bioSize.height+40
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        bioLabel.text = nil

    }

    public func configure(with viewModel: ProfileHeaderViewModel) {
        imageView.sd_setImage(with: viewModel.profilePictureUrl, completed: nil)

        // if there's username, show it before the welcome text
        var text = ""
        if let name = viewModel.name {
            text = name + "\n"
        }
        text += viewModel.bio ?? "Welcome to my profile!"
        bioLabel.text = text

        // Container
        let containerViewModel = ProfileHeaderCountViewViewModel(
            followerCount: viewModel.followerCount,
            followingCount: viewModel.followingICount,
            postsCount: viewModel.postCount,
            actionType: viewModel.buttonType
        )
        countContainerView.configure(with: containerViewModel)
    }

}
