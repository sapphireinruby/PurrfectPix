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

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false // don't forget this line
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
//        clipsToBounds = true
        contentView.addSubview(label)

        // Add constraints
        // TODO auto height
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
//            label.widthAnchor.constraint(equalToConstant: contentView.width - padding)
//            label.heightAnchor.constraint(equalToConstant: 200)
//            label.heightAnchor.constraint(equalToConstant: self.label.height)
        ])
    }


    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
//        label.frame = CGRect(x: 24, y: 0, width: contentView.width-48, height: contentView.height)
    }

    func configure(with model: Comment) {

        label.attributedText = NSMutableAttributedString()
            .boldP1("\(model.username) ")
            .normal("\(model.comment)")
        label.sizeToFit()
    }
}
