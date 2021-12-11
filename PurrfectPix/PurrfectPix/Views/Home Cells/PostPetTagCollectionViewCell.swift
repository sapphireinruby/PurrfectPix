//
//  PostPetTagCollectionViewCell.swift
//  PurrfectPix
//
//  Created by Amber on 10/20/21.
//

import UIKit
import TTGTags

protocol PostPetTagCollectionViewCellDelegate: AnyObject {
    func postPetTagCollectionViewCellDidTapPresentTagView(_ cell: PostPetTagCollectionViewCell)

}

class PostPetTagCollectionViewCell: UICollectionViewCell, TTGTextTagCollectionViewDelegate {

    static let identifier = "PostPetTagCollectionViewCell"

    // use delagate weak to avoid the risk of a "strong reference cycle" aka “retain cycle”
    weak var delegate: PostPetTagCollectionViewCellDelegate?

    private let presentTagView = TTGTextTagCollectionView()

        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.clipsToBounds = true
            contentView.backgroundColor = .systemBackground
            contentView.addSubview(presentTagView)

            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPresentTagView))
            presentTagView.addGestureRecognizer(tap)
        }

    @objc func didTapPresentTagView() {
        delegate?.postPetTagCollectionViewCellDidTapPresentTagView(self)
    }

    required init? (coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        presentTagView.alignment = .left

        presentTagView.frame = CGRect(
            x: 24,
            y: 16,
            width: contentView.width - 48,
            height: contentView.height  // 60

        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        presentTagView.removeAllTags()
    }

    func configure(with viewModel: PostPetTagCollectionViewCellViewModel) {

        let petTag = viewModel.petTag

        for text in petTag {

            let content = TTGTextTagStringContent.init(text: text)
//            content.textFont = UIFont.boldSystemFont(ofSize: 12)
            content.textColor = .label

            // nomore tag
            let normalStyle = TTGTextTagStyle.init()
            normalStyle.backgroundColor = .secondarySystemBackground
            normalStyle.extraSpace = CGSize.init(width: 12, height: 12)
            normalStyle.borderColor = UIColor.P1!
            normalStyle.borderWidth = 1

            let tag = TTGTextTag.init()
            tag.content = content
            tag.style = normalStyle

            presentTagView.addTag(tag)
        }
    }

}
