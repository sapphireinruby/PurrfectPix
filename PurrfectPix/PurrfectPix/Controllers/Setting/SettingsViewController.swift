//
//  SettingViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import UIKit
import SafariServices

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")
        return table
    }()

    private var sections: [SettingsSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
         // tableView
        view.addSubview(tableView)
        configureModels()
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
        createTableFooter()

    }


    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    private func configureModels() {
        sections.append(
            SettingsSection(title: "We Hope you Enjoy PurrfectPix", options: [
                SettingOption(
                    title: "Rate PurrfectPix",
                    image: UIImage(systemName: "star"),
                    color: .systemGray2
                ) {

                },
                SettingOption(
                    title: "Share PurrfectPix",
                    image: UIImage(systemName: "square.and.arrow.up"),
                    color: .systemGray2
                ) {

                }
            ])
        )

        sections.append(
            SettingsSection(title: "Information", options: [
                SettingOption(
                    title: "End User License Agreement",
                    image: UIImage(systemName: "doc"),
                    color: .P2!
                ) { [weak self] in
                    DispatchQueue.main.async {
                        guard let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") else {
                            return
                        }
                        let vcSF = SFSafariViewController(url: url)
                        self?.present(vcSF, animated: true, completion: nil)
                    }
                },
                SettingOption(
                    title: "Privacy Policy",
                    image: UIImage(systemName: "hand.raised"),
                    color: .P1!
                ) { [weak self] in
                    guard let url = URL(string: "https://www.privacypolicies.com/live/dd1fde8e-ef94-48a1-8b08-49b95c29ac5e") else {
                        return
                    }
                    let vc = SFSafariViewController(url: url)
                    self?.present(vc, animated: true, completion: nil)

                },
                SettingOption(
                    title: "Contact PurrfectPix",
                    image: UIImage(systemName: "message"),
                    color: .P2!
                ) {

                },
                SettingOption(
                    title: "Delete Account",
                    image: UIImage(systemName: "minus.circle"),
                    color: .systemPink
                ) {

                    let actionSheet = UIAlertController(
                        title: "Delete Account",
                        message: "All posts from your account will be deleted, are you sure?",
                        preferredStyle: .actionSheet
                    )
                    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    actionSheet.addAction(UIAlertAction(title: "Contact Us to Delete Your Account", style: .destructive, handler: { [weak self] _ in
                        AuthManager.shared.signOut { success in
                            if success {
                                DispatchQueue.main.async {
                                    let vc = SignInViewController()
                                    let navVC = UINavigationController(rootViewController: vc)
                                    navVC.modalPresentationStyle = .fullScreen
                                    self?.present(navVC, animated: true)
                                }
                            }
                        }
                    }))
                    self.present(actionSheet, animated: true)

                }
            ])
        )
    }

    // Table

    private func createTableFooter() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 50))
        footer.clipsToBounds = true

        let button = UIButton(frame: footer.bounds)
        footer.addSubview(button)
        button.setTitle("Sign Out",
                        for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(didTapSignOut), for: .touchUpInside)

        tableView.tableFooterView = footer
    }

    @objc func didTapSignOut() {
        let actionSheet = UIAlertController(
            title: "Sign Out",
            message: "Are you sure?",
            preferredStyle: .actionSheet
        )
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { [weak self] _ in
            AuthManager.shared.signOut { success in
                if success {
                    DispatchQueue.main.async {
                        let vc = SignInViewController()
                        let navVC = UINavigationController(rootViewController: vc)
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true)
                    }
                }
            }
        }))
        present(actionSheet, animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        cell.imageView?.image = model.image
        cell.imageView?.tintColor = model.color
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

}
