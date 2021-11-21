//
//  PostCaptionCollectionViewCell.swift
//  PurrfectPix
//
//  Created by Amber on 10/20/21.
//

import UIKit

protocol PostCaptionCollectionViewCellDelegate: AnyObject {
    func postCaptionCollectionViewCellDidTapCaptioon(_ cell: PostCaptionCollectionViewCell)
}

class PostCaptionCollectionViewCell: UICollectionViewCell {

    static let identifer = "PostCaptionCollectionViewCell"

    weak var delegate: PostCaptionCollectionViewCellDelegate?


    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0 //for line wrap
        label.isUserInteractionEnabled = true
        return label

    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)

        // for target action
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(didTapCaption))
        label.addGestureRecognizer(tap)
    }

    required init? (coder: NSCoder) {
        fatalError()
    }

    @objc func didTapCaption() {
        delegate?.postCaptionCollectionViewCellDidTapCaptioon(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

//        // autolayout for autoheight
//        NSLayoutConstraint.activate([
//            label.leadingAnchor.constraint(equalTo: superview!.safeAreaLayoutGuide.leadingAnchor),
//            label.trailingAnchor.constraint(equalTo: superview!.safeAreaLayoutGuide.trailingAnchor),
//            label.topAnchor.constraint(equalTo: superview!.safeAreaLayoutGuide.topAnchor),
//            label.bottomAnchor.constraint(equalTo: superview!.safeAreaLayoutGuide.bottomAnchor)
//        ])

        let size = label.sizeThatFits(CGSize(
            width: contentView.bounds.size.width - 48,
            height: contentView.bounds.size.height ))
        // type CGFloat
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
        let labelName = "\(viewModel.username) " 
        let labelCap = "\(viewModel.caption ?? "")"
        label.text = labelName + labelCap

        label.attributedText = NSMutableAttributedString()
            .boldP2("\(viewModel.username) ")
            .normal("\(viewModel.caption ?? "")") 

//        label.text = "\(viewModel.username): \(viewModel.caption ?? "")"
        // if not nil, not showing the "optional"
//        label.textColor = .P1
    }

}
