//
//  PhotoCollectionViewCell.swift
//  PurrfectPix
//
//  Created by Amber on 10/22/21.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    // for Edit post filter and explore view

    static let identifier = "PhotoCollectionViewCell"

    private let imageView: UIImageView = {

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tintColor = .label // fits both mode
        return imageView

    }()

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.textColor = .P1
        return label

    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(label)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size: CGFloat = contentView.height
        imageView.frame = contentView.bounds
        label.sizeToFit()
        label.frame = CGRect(x: 0,
                             y: 40,
                             width: size,
                             height: size
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        label.text = nil
    }

    func configure(style: String) {
        imageView.image = UIImage(systemName: "camera.filters")
        imageView.tintColor = .darkGray
        label.text = style
        
    }

    // explore view
    func configure(with url: URL?) {
        imageView.sd_setImage(with: url, completed: nil)
    }

    func configure(with image: UIImage?) {
        imageView.image = image
    }
    
}
