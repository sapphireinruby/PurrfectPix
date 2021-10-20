//
//  PosterCollectionViewCell.swift
//  PurrfectPix
//
//  Created by Amber on 10/20/21.
//

import UIKit
import SDWebImage

final class PosterCollectionViewCell: UICollectionViewCell {
    
    static let identifer = "PosterCollectionViewCell"

    private let imageView: UIImageView = {

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView

    }() // closure

    private let usernameLabel: UILabel = {

        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()

    private let moreButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(named: "More-Alt")
//        let image = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25  ))
        button.setImage(image, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        // add views
        contentView.addSubview(imageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(moreButton)
        // set target-action for more button
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)

    }

    @objc func didTapMore() {
        // set up later
    }

    required init? (coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // set the subview layouts
        let imagePadding: CGFloat = 4
        let imageSize: CGFloat = contentView.height - (imagePadding * 2)

        // protfile image
        imageView.frame = CGRect(x: imagePadding * 4,
                                 y: imagePadding,
                                 width: imageSize,
                                 height: imageSize
        )
        imageView.layer.cornerRadius = imageSize / 2

        // usernameLabel
        usernameLabel.sizeToFit()
        usernameLabel.frame = CGRect(x: imageView.right + 16,
                                     y: 0,
                                     width: usernameLabel.width,
                                     height: contentView.height
        )

        // moreButton
        moreButton.frame = CGRect(x: contentView.width - 55,
                                  y: (contentView.height - 50) / 2,
                                  width: 55,
                                  height: 55
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // to reset each time it launch
        usernameLabel.text = nil
        imageView.image = nil

    }

    func configure(with viewModel: PosterCollectionViewCellViewModel) {
        // the username that setted up on viewModel file, will get from data

        usernameLabel.text = viewModel.username
        imageView.sd_setImage(with: viewModel.profilePictureURL, completed: nil)

    }

}
