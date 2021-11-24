//
//  CommentBarView.swift
//  PurrfectPix
//
//  Created by Amber on 11/19/21.
//

import UIKit

protocol CommentBarViewDelegate: AnyObject {
    func commentBarViewDidTapDone(_ commentBarView: CommentBarView, withText text: String)
}

final class CommentBarView: UIView, UITextFieldDelegate {

    weak var delegate: CommentBarViewDelegate?

    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.P2, for: .normal)
        return button
    }()

    let textfield: UserTextField = {
        let textfield = UserTextField()
        textfield.placeholder = "Comment this cure pix..."
        textfield.backgroundColor = .secondarySystemBackground
        return textfield
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(textfield)
        addSubview(button)
        textfield.delegate = self
        button.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        backgroundColor = .tertiarySystemBackground
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc func didTapComment() {
        guard let text = textfield.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        delegate?.commentBarViewDidTapDone(self, withText: text)
        textfield.resignFirstResponder()
        textfield.text = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        button.sizeToFit()
        button.frame = CGRect(x: width-button.width-24, // 12-text-button-12
                              y: (height-button.height)/2, //
                              width: button.width,
                              height: button.height)

        textfield.frame = CGRect(x: 16, y: (height-50)/2,
                                 width: width-button.width-56,
                                 height: 40)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textfield.resignFirstResponder()
        didTapComment()
        return true
    }
}
