//
//  PostLikesCollectionViewCell.swift
//  PurrfectPix
//
//  Created by Amber on 10/20/21.
//

import UIKit

class PostLikesCollectionViewCell: UICollectionViewCell {

    static let identifer = "PostLikesCollectionViewCell"

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label

    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)
    }

    required init? (coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.sizeToFit()
        label.frame = CGRect(x: 24,
                             y: 0,
                             width: label.width,
                             height: contentView.height
        )

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }

    func configure(with viewModel: PostLikesCollectionViewCellViewModel) {

        let users = viewModel.likers
        label.text = "\(users.count) Likes"

    }

}
