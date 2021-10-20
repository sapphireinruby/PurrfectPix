//
//  PostDateTimeCollectionViewCell.swift
//  PurrfectPix
//
//  Created by Amber on 10/20/21.
//

import UIKit

class PostDateTimeCollectionViewCell: UICollectionViewCell {

    static let identifer = "PostDateTimeCollectionViewCell"

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondarySystemBackground
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

    func configure(with viewModel: PostDatetimeCollectionViewCellViewModel) {
        let date = viewModel.date
        // form extsion
        label.text = String.date(from: date)

    }

}
