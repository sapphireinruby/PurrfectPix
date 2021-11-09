//
//  ProfileViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import UIKit

class ProfileViewController: UIViewController {

    private let user: User

    private var isCurrentUser: Bool {
        return user.username.lowercased() == AuthManager.shared.username?.lowercased() ?? ""
    }

    // MARK: - Init
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = user.username.uppercased()
        view.backgroundColor = .systemBackground
        configure()
    }

    private func configure() {
        if isCurrentUser {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "gear"),
                style: .done,
                target: self,
                action: #selector(didTapSettings)
            )
        }
    }

    @objc func didTapSettings() {
        let settingVC = SettingsViewController()
        present(UINavigationController(rootViewController: settingVC), animated: true)
    }

}
