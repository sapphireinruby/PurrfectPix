//
//  PhotoCollectionViewCell.swift
//  PurrfectPix
//
//  Created by Amber on 10/22/21.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    static let identifier = "PhotoCollectionViewCell"

    private let imageView: UIImageView = {

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        imageView.tintColor = .label // fits both mode
        return imageView

    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    func configure(with image: UIImage?, style: String) {
        // 把filter title 塞進去
        imageView.image = image
        
    }

    func configure(with url: URL?) {
        imageView.sd_setImage(with: url, completed: nil)
    }
    
}
