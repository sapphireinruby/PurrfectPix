//
//  ProfileHeaderCollectionReusableView.swift
//  PurrfectPix
//
//  Created by Amber on 11/13/21.
//

import UIKit

class ProfileHeaderCollectionReusableView: UICollectionReusableView {

    static let identifier = "ProfileHeaderCollectionReusableView"

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemPink
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    public func configure(with viewModel: ProfileHeaderViewModel){

    }
}
