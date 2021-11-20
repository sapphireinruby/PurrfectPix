//
//  EditProfileViewController.swift
//  PurrfectPix
//
//  Created by Amber on 11/14/21.
//

import UIKit

class EditProfileViewController: UIViewController {

    public var completion: (() -> Void)?

    // Fields
    let nameField: UserTextField = {
        let field = UserTextField()
        field.placeholder = "Name"
        return field
    }()

    private let bioField: UserTextField = {
        let field = UserTextField()
        field.placeholder = "Tell us about you and your pet here!"
        return field
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit User Name and Bio"
        view.backgroundColor = .systemBackground
        view.addSubview(nameField)
        view.addSubview(bioField)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(didTapSave))


        guard let userID = AuthManager.shared.userID else { return }
        DatabaseManager.shared.getUserInfo(userID: userID) { [weak self] info in
            DispatchQueue.main.async {
                if let info = info {
                    // showing current user info in the edit field
                    self?.nameField.text = info.username
                    self?.bioField.text = info.bio
                }
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nameField.frame = CGRect(x: 24,
                                 y: view.safeAreaInsets.top+10,
                                 width: view.width-48,
                                 height: 50)
        bioField.frame = CGRect(x: 24,
                                   y: nameField.bottom+10,
                                   width: view.width-48,
                                   height: 120)
    }

    // Actions

    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }

    @objc func didTapSave() {
        let name = nameField.text ?? ""
        let bio = bioField.text ?? ""
        DatabaseManager.shared.setUserInfo(name: name, bio: bio) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.completion?()
                    self?.didTapClose()
                }
            }
        }
    }
}
