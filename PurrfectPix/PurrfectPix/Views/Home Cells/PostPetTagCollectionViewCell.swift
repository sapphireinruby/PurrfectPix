//
//  PostPetTagCollectionViewCell.swift
//  PurrfectPix
//
//  Created by Amber on 10/20/21.
//

import UIKit

class PostPetTagCollectionViewCell: UICollectionViewCell {

    // cell 上面顯示的字串 不要改成tag collection view
    static let identifer = "PostPetTagCollectionViewCell"

    private let petTagLabel: UILabel = {

        let label = UILabel()
//        label.font = .systemFont(ofSize: 14, weight: .regular)

        label.font = UIFont.italicSystemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
//        label.textColor = .secondarySystemBackground
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(petTagLabel)
    }

    required init? (coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // petTagLabel
        petTagLabel.sizeToFit()
        petTagLabel.frame = CGRect(x: 24,
                                   y: 0,
                                   width: petTagLabel.width,
                                   height: contentView.height
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        petTagLabel.text = nil
    }

    func configure(with viewModel: PostPetTagCollectionViewCellViewModel) {

        let petTag = viewModel.petTag
        petTagLabel.text = "# \(petTag)"

    }

}
