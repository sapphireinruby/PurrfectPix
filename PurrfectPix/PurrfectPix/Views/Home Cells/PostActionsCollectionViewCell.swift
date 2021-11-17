//
//  PostActionsCollectionViewCell.swift
//  PurrfectPix
//
//  Created by Amber on 10/20/21.
//

import UIKit

protocol PostActionsCollectionViewCellDelegate: AnyObject {

    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool, index: Int)

    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell)
    
    func postActionsCollectionViewCellDidTapShare(_ cell: PostActionsCollectionViewCell)
}

class PostActionsCollectionViewCell: UICollectionViewCell {

    static let identifer = "PostActionsCollectionViewCell"

    private var index = 0

    weak var delegate: PostActionsCollectionViewCellDelegate?

    private var isLiked = false

    // set up 3 buttons
    private let likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(named: "Heart-purple")
        button.setImage(image, for: .normal)
        return button
    }() // closure

    private let commentButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(named: "Comment-Alt")
        button.setImage(image, for: .normal)
        return button
    }()

    private let shareButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(named: "Paper Plane")
        button.setImage(image, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
//        // hide share
//        contentView.addSubview(shareButton)

        // three target actions
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
//        // hide share
//        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)

    }

    required init? (coder: NSCoder) {
        fatalError()
    }

    // three actions

    @objc func didTapLike() {
        // the viewModel knows if it's liked
//        // will inverse the isLike Bool, preset it to flase earlier

        // do the heart change directly
        if self.isLiked {
            let image = UIImage(named: "Heart-purple")
            likeButton.setImage(image, for: .normal)

        } else {
            let image = UIImage(named: "Heart-filled")
            likeButton.setImage(image, for: .normal)
//            likeButton.tintColor = .systemRed
        }

        delegate?.postActionsCollectionViewCellDidTapLike(self,
                                                          isLiked: !isLiked,
                                                          index: index)
        self.isLiked = !isLiked  // to enable doing the switch
    }

    @objc func didTapComment() {

    }

//    // hide share
//    @objc func didTapShare() {
//
//    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size: CGFloat = (contentView.height) / 1.5

        likeButton.frame = CGRect(
            x: 24,
            y: (contentView.height - size) / 2,
            width: size,
            height: size
        )

        commentButton.frame = CGRect(
            x: likeButton.right + 24,
            y: (contentView.height - size) / 2,
            width: size,
            height: size
        )

        shareButton.frame = CGRect(
            x: commentButton.right + 24,
            y: (contentView.height - size) / 2,
            width: size,
            height: size
        )

    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func configure(with viewModel: PostActionsCollectionViewCellViewModel) {
        // to save if is liked or not
        isLiked = viewModel.isLiked

        if viewModel.isLiked {
            let image = UIImage(named: "Heart-filled")
            likeButton.setImage(image, for: .normal)

        } else {
            let image = UIImage(named: "Heart-purple")
            likeButton.setImage(image, for: .normal)
        }

    }

}
