//
//  PosterCollectionViewCell.swift
//  PurrfectPix
//
//  Created by Amber on 10/20/21.
//

import UIKit
import SDWebImage

protocol PosterCollectionViewCellDelegate: AnyObject {
    func posterCollectionViewCellDidTapMore(_ cell: PosterCollectionViewCell, index: Int)
    func posterCollectionViewCellDidTapUsername(_ cell: PosterCollectionViewCell, index: Int)
    func posterCollectionViewCellDidTapUserPic(_ cell: PosterCollectionViewCell, index: Int)
}

final class PosterCollectionViewCell: UICollectionViewCell {
    
    static let identifer = "PosterCollectionViewCell"

    private var index = 0

    // use delagate weak to avoid the risk of a "strong reference cycle" aka “retain cycle”
    weak var delegate: PosterCollectionViewCellDelegate?

    private let imageView: UIImageView = {

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView

    }() // closure

    private let usernameLabel: UILabel = {

        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()

    private let moreButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(named: "More-Alt")
        button.setImage(image, for: .normal)
        return button
    }()

    // init with frame setting
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

        // tap gesture recognizer for tap username to open profile page
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapUsername))
        usernameLabel.isUserInteractionEnabled = true // tap the name to show the user profile
        usernameLabel.addGestureRecognizer(tap)

        // tap user picture
        let tapPic = UITapGestureRecognizer(target: self, action: #selector(didTapUserPic))
        imageView.isUserInteractionEnabled = true // tap the name to show the user profile
        imageView.addGestureRecognizer(tapPic)


    }

    // action selector
    @objc func didTapMore() {
        delegate?.posterCollectionViewCellDidTapMore(self, index: index)
        // passing a reference of caller of a delegate function
    }

    @objc func didTapUsername() {
        delegate?.posterCollectionViewCellDidTapUsername(self, index: index)
    }

    @objc func didTapUserPic() {
        delegate?.posterCollectionViewCellDidTapUserPic(self, index: index)
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
        imageView.frame = CGRect(x: imagePadding * 6,
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
        moreButton.frame = CGRect(x: contentView.width-55-16,
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

    func configure(with viewModel: PosterCollectionViewCellViewModel, index: Int) {
        // the username that setted up on viewModel file, will get from data

        self.index = index

        usernameLabel.text = viewModel.username
//        imageView.sd_setImage(with: viewModel.profilePictureURL, completed: nil)
        imageView.sd_setImage(with:  viewModel.profilePictureURL, placeholderImage: UIImage(systemName: "person.circle"))
        imageView.tintColor = .P1

    }

}
