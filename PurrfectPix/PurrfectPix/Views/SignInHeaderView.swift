//
//  SignInHeaderView.swift
//  PurrfectPix
//
//  Created by Amber on 10/24/21.
//

import UIKit

class SignInHeaderView: UIView {

    private let imageView: UIImageView = {

        let imageView = UIImageView()
        imageView.image = UIImage(named: "PurrfectPix_textlogo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var gradientLayer: CALayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        createGradient()
        addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func createGradient() {

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
        layer.addSublayer(gradientLayer)
        self.gradientLayer = gradientLayer

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = layer.bounds
        imageView.frame = CGRect(x: width/4, y: 20, width: width/2, height: height - 40)
    }

}
