//
//  PostActionsCollectionViewCell.swift
//  PurrfectPix
//
//  Created by Amber on 10/20/21.
//

import UIKit

class PostActionsCollectionViewCell: UICollectionViewCell {

    static let identifer = "PostActionsCollectionViewCell"

    // set up 3 button

    private let likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(named: "Heart-purple")
//        let image = UIImage(systemName: "Heart-purple", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
        button.setImage(image, for: .normal)
        return button
    }() // closure

    private let commentButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(named: "Comment-Alt")
//        Comment-Alt Message-Happy Message-3
//        let image = UIImage(systemName: "Basic Elaboration Message Happy", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
        button.setImage(image, for: .normal)
        return button
    }()

    private let shareButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(named: "Paper Plane")
//        let image = UIImage(systemName: "Paper Plane", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
        button.setImage(image, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(shareButton)

        // three target actions
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)


    }

    required init? (coder: NSCoder) {
        fatalError()
    }

    // three actions

    @objc func didTapLike() {

    }

    @objc func didTapComment() {

    }

    @objc func didTapShare() {

    }


    override func layoutSubviews() {
        super.layoutSubviews()
        let size: CGFloat = (contentView.height) / 1.7
        likeButton.frame = CGRect(x: 16, y: (contentView.height - size) / 2, width: size, height: size)
        commentButton.frame = CGRect(x: likeButton.right + 20, y: (contentView.height - size) / 2, width: size, height: size)
        shareButton.frame = CGRect(x: commentButton.right + 20, y: (contentView.height - size) / 2, width: size, height: size)

    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func configure(with viewModel: PostActionsCollectionViewCellViewModel) {

        if viewModel.isLiked {

            let image = UIImage(named: "Heart-filled")
            likeButton.setImage(image, for: .normal)

        }
    }

}
