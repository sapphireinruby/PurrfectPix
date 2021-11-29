//
//  CommentCollectionViewCell.swift
//  PurrfectPix
//
//  Created by Amber on 11/19/21.
//

import UIKit

class CommentCollectionViewCell: UICollectionViewCell {

    static let identifier = "CommentCollectionViewCell"

    private let padding: CGFloat = 24

    private let paddingV: CGFloat = 4

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false // don't forget this line
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        contentView.addSubview(label)

        // TODO auto height
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: paddingV),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: paddingV),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)

        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 24, y: 0, width: contentView.width-48, height: contentView.height)
    }

    func configure(with model: Comment) {

        label.attributedText = NSMutableAttributedString()
            .boldP1("\(model.username) ")
            .normal("\(model.comment)")
        label.sizeToFit()
    }
}
