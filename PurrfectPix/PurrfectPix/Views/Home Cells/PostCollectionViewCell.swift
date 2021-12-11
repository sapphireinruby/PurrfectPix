//
//  PostCollectionViewCell.swift
//  PurrfectPix
//
//  Created by Amber on 10/20/21.
//

import UIKit
import SDWebImage

protocol PostCollectionViewCellDelegate: AnyObject {
    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell, index: Int)
    // for double tap on the image to like, but cannot unlike
}

class PostCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PostCollectionViewCell"

    weak var delegate: PostCollectionViewCellDelegate?

    private var index = 0 // need index to get post

    private let imageView: UIImageView = {

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView

    }()

    // for double tap showing heart to like the post
    private let heartImageView: UIImageView = {
        let image = UIImage(named: "Heart-filled")
        let imageView = UIImageView(image: image)
        imageView.isHidden = true
        imageView.alpha = 0 // animate the actual alpha at action
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        // add subview of the heart
        contentView.addSubview(imageView)

        // double tap showing heart to like the post
        contentView.addSubview(heartImageView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapToLike))
        tap.numberOfTapsRequired = 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)

    }

    required init? (coder: NSCoder) {
        fatalError()
    }

    @objc func didDoubleTapToLike() {

            heartImageView.isHidden = false

            // animate
            UIView.animate(withDuration: 1) {
                self.heartImageView.alpha = 1
            } completion: { done in
                if done {
                    UIView.animate(withDuration: 0.4) {
                        self.heartImageView.alpha = 0
                    } completion: { done in
                        if done {
                            self.heartImageView.isHidden = true
                            self.delegate?.postCollectionViewCellDidLike(self, index: self.index)
                        }
                    }
                }
            }


    }

    override func layoutSubviews() {
        
        super.layoutSubviews()
        // set the subview layouts
        imageView.frame = contentView.frame
        // to the whole frame

        // double tap heart
        let size: CGFloat = contentView.width/5
        heartImageView.frame = CGRect(
            x: (contentView.width-size)/2,
            y: (contentView.height-size)/2,
            width: size,
            height: size)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    func configure(with viewModel: PostCollectionViewCellViewModel, index: Int) {
        
        self.index = index
        imageView.sd_setImage(with: viewModel.postUrl, completed: nil)
    }

}
