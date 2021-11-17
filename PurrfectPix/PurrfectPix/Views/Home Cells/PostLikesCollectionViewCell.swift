//
//  PostLikesCollectionViewCell.swift
//  PurrfectPix
//
//  Created by Amber on 10/20/21.
//

import UIKit

protocol PostLikesCollectionViewCellDelegate: AnyObject {

    func postLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell, index: Int)
}

class PostLikesCollectionViewCell: UICollectionViewCell {

    static let identifer = "PostLikesCollectionViewCell"

    weak var delegate: PostLikesCollectionViewCellDelegate?

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1

        label.isUserInteractionEnabled = true

        return label

    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(didTapLabel))
        label.addGestureRecognizer(tap)
    }

    @objc func didTapLabel() {
//        delegate?.postLikesCollectionViewCellDidTapLikeCount(self, index: 3)
        // 問collection view 找這個cell 的位置,  目前找不到 所以先槓槓起來
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
