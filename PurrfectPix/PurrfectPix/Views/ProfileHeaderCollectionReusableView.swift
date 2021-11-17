//
//  ProfileHeaderCollectionReusableView.swift
//  PurrfectPix
//
//  Created by Amber on 11/13/21.
//

import UIKit

protocol ProfileHeaderCollectionReusableViewDelegate: AnyObject {
    func profileHeaderCollectionReusableViewDidTapProfilePicture(_ header: ProfileHeaderCollectionReusableView)
}

class ProfileHeaderCollectionReusableView: UICollectionReusableView {

    static let identifier = "ProfileHeaderCollectionReusableView"

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        // for change profile image
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()

    weak var delegate: ProfileHeaderCollectionReusableViewDelegate?

    public let countContainerView = ProfileHeaderCountView()  // make it public so ProfileVC can use it

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
        addSubview(bioLabel)
        // for change profile image
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        imageView.addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc func didTapImage() {
        delegate?.profileHeaderCollectionReusableViewDidTapProfilePicture(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // profile picture
        let imageSize: CGFloat = width/3.5
        imageView.frame = CGRect(x: 16, y: 4, width: imageSize, height: imageSize)
        imageView.layer.cornerRadius = imageSize/2

        // 3 profile counts and profile button: edit or follow
        countContainerView.frame = CGRect(
            x: imageView.right+8,
            y: 3,
            width: width-imageView.right-24,
            height: imageSize
        )

        let bioSize = bioLabel.sizeThatFits(
            bounds.size
        )
        bioLabel.frame = CGRect(
            x: 16,
            y: imageView.bottom + 8,
            width: width - 32,
            height: bioSize.height + 40
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
        if let username = viewModel.username {
            text = username + "\n"
        }
        text += viewModel.bio ?? "Welcome to my profile!"
        bioLabel.text = text

//        // hide container view
//        // Container
        let containerViewModel = ProfileHeaderCountViewViewModel(
            followerCount: viewModel.followerCount,
            followingCount: viewModel.followingICount,
            postsCount: viewModel.postCount,
            actionType: viewModel.buttonType
        )
        countContainerView.configure(with: containerViewModel)
    }

}
