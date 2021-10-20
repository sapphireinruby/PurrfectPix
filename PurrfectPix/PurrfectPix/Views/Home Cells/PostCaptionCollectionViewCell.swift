//
//  PostCaptionCollectionViewCell.swift
//  PurrfectPix
//
//  Created by Amber on 10/20/21.
//

import UIKit

class PostCaptionCollectionViewCell: UICollectionViewCell {

    static let identifer = "PostCaptionCollectionViewCell"

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0 //for line wrap
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

        let size = label.sizeThatFits(CGSize(width: contentView.bounds.size.width - 16, height: contentView.bounds.size.height )) //type CGFloat
        // to return the size to fit the given label

        label.frame = CGRect(x: 24,
                             y: 4,
                             width: size.width,
                             height: size.height
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }

    func configure(with viewModel: PostCaptionCollectionViewCellViewModel) {

//        label.text = "\(viewModel.username): \(viewModel.caption)"  // showing comment with "optional"

        label.text = "\(viewModel.username): \(viewModel.caption ?? "")"  // if not nil, not showing the "optional"


    }

}
