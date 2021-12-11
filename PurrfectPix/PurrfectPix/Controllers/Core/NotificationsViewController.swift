//
//  NotificationsViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/17/21.
//

import UIKit
import Lottie

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let noActivityLabel: UILabel = {
        let label = UILabel()
        label.text = "No Notifications"
        label.textColor = .P1
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private var viewModels: [NotificationCellType] = []  // to hold view models
    private var models: [PurrNotification] = [] // to hold models

    // MARK: - Lifecycle

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.isHidden = true
        table.register(
            LikeNotificationTableViewCell.self,
            forCellReuseIdentifier: LikeNotificationTableViewCell.identifer
        )
        table.register(
            CommentNotificationTableViewCell.self,
            forCellReuseIdentifier: CommentNotificationTableViewCell.identifer
        )
        table.register(
            FollowNotificationTableViewCell.self,
            forCellReuseIdentifier: FollowNotificationTableViewCell.identifer
        )
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notifications"
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(noActivityLabel)
        fetchNotifications()

}

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noActivityLabel.sizeToFit()
        noActivityLabel.center = view.center
    }

    private func fetchNotifications() {
        NotificationsManager.shared.getNotifications { [weak self] models in
            DispatchQueue.main.async {
                self?.models = models
                self?.createViewModels()
            }
        }
    }

    // Creates viewModels from models for notification
    // swiftlint:disable function_body_length
    private func createViewModels() {

        models.forEach { model in
            guard let type = NotificationsManager.PurrNotifyType(rawValue: model.notificationType) else {
                return
            }
            let fromUsername = model.fromUserID
            guard let profilePictureUrl = URL(string: model.profilePictureUrl) else {
                return
            }

            switch type {
            case .like:
                guard let postUrl = URL(string: model.postUrl ?? "") else {
                    return
                }
                viewModels.append(
                    .like(
                        viewModel: LikeNotificationCellViewModel(
                            fromUsername: fromUsername,
                            profilePictureUrl: profilePictureUrl,
                            postUrl: postUrl,
                            date: model.dateString
                        )
                    )
                )
            case .comment:
                guard let postUrl = URL(string: model.postUrl ?? "") else {
                    return
                }
                viewModels.append(
                    .comment(
                        viewModel: CommentNotificationCellViewModel(
                            fromUsername: fromUsername,
                            profilePictureUrl: profilePictureUrl,
                            postUrl: postUrl,
                            date: model.dateString
                        )
                    )
                )
            case .follow:
                guard let isFollowing = model.isFollowing else {
                    return
                }
                viewModels.append(
                    .follow(
                        viewModel: FollowNotificationCellViewModel(
                            fromUsername: fromUsername,
                            profilePictureUrl: profilePictureUrl,
                            isCurrentUserFollowing: isFollowing,
                            date: model.dateString
                        )
                    )
                )
            }
        }

        if viewModels.isEmpty {
            noActivityLabel.isHidden = false
            tableView.isHidden = true
        } else {
            noActivityLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }

    // Creates mock data for testing
    private func mockData() {
        tableView.isHidden = false
        guard let postUrl = URL(string: "https://www.chagougou.com/uploads/200317/1-20031G54F4616.jpg") else {
            return
        }
        guard let iconUrl = URL(string: "https://www.numerator.com/sites/default/files/styles/banner_960x380_/public/image/2019-05/Dog%2BCat.jpg?itok=1FKMdx98") else {
            return
        }

        viewModels = [
            .like(
                viewModel: LikeNotificationCellViewModel(
                    fromUsername: "Zoe",
                    profilePictureUrl: iconUrl,
                    postUrl: postUrl,
                    date: "March 12"
                )
            ),
            .comment(
                viewModel: CommentNotificationCellViewModel(
                    fromUsername: "Elio",
                    profilePictureUrl: iconUrl,
                    postUrl: postUrl,
                    date: "March 12"
                )
            ),
            .follow(
                viewModel: FollowNotificationCellViewModel(
                    fromUsername: "Ed",
                    profilePictureUrl: iconUrl,
                    isCurrentUserFollowing: true,
                    date: "March 12"
                )
            )
        ]

        tableView.reloadData()
    }

    // MARK: - Notifications TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = viewModels[indexPath.row]
        switch cellType {
        case .follow(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: FollowNotificationTableViewCell.identifer,
                for: indexPath
            ) as? FollowNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        case .like(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: LikeNotificationTableViewCell.identifer,
                for: indexPath
            ) as? LikeNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        case .comment(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CommentNotificationTableViewCell.identifer,
                for: indexPath
            ) as? CommentNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // tap to open porfile fromUsername

        tableView.deselectRow(at: indexPath, animated: true)
        let cellType = viewModels[indexPath.row]
        let fromUsername: String
        switch cellType {
        case .follow(let viewModel):
            fromUsername = viewModel.fromUsername
        case .like(let viewModel):
            fromUsername = viewModel.fromUsername
        case .comment(let viewModel):
            fromUsername = viewModel.fromUsername
        }

        DatabaseManager.shared.findUser(with: fromUsername) { [weak self] user in
            guard let user = user else {
                // Show error alert
                return
            }

            DispatchQueue.main.async {
                let vc = ProfileViewController(userID: user.userID)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

// MARK: - Notifications Actions

extension NotificationsViewController: LikeNotificationTableViewCellDelegate, CommentNotificationTableViewCellDelegate, FollowNotificationTableViewCellDelegate {
    func likeNotificationTableViewCell(_ cell: LikeNotificationTableViewCell,
                                       didTapPostWith viewModel: LikeNotificationCellViewModel) {
        guard let index = viewModels.firstIndex(where: {
            // use index to get model out, make Not. structs Equatable
            switch $0 {
            case .comment, .follow: // not related to likes
                return false
            case .like(let current):
                return current == viewModel
            }
        }) else {
            return
        }

        openPost(with: index, fromUsername: viewModel.fromUsername)
    }

    func commentNotificationTableViewCell(_ cell: CommentNotificationTableViewCell,
                                          didTapPostWith viewModel: CommentNotificationCellViewModel) {
        guard let index = viewModels.firstIndex(where: {

            switch $0 {
            case .like, .follow:
                return false // not related to comment
            case .comment(let current):
                return current == viewModel
            }
        }) else {
            return
        }

        openPost(with: index, fromUsername: viewModel.fromUsername)
    }

    func followNotificationTableViewCell(
        _ cell: FollowNotificationTableViewCell,
        didTapButton isFollowing: Bool,
        viewModel: FollowNotificationCellViewModel
    ) {
        let fromUsername = viewModel.fromUsername
//        DatabaseManager.shared.updateRelationship(
//            state: isFollowing ? .follow : .unfollow, // if is following, unfollow
//            for: fromUsername
//        ) {{ [weak self] success in
//            if !success {
//                DispatchQueue.main.async {
//                    let alert = UIAlertController(
//                        title: "Woops",
//                        message: "Unable to perform action.",
//                        preferredStyle: .alert
//                    )
//                    alert.addAction(
//                        UIAlertAction(
//                            title: "Dismiss",
//                            style: .cancel,
//                            handler: nil
//                        )
//                    )
//                    self?.present(alert, animated: true)
//                }
//            }
//        }}
    }

    func openPost(with index: Int, fromUsername: String) {
        // open post from notification
        // find post by id from index
        guard index < models.count else {
            return
        }

        let model = models[index]
        let fromUsername = fromUsername
        guard let postID = model.postId else {
            return
        }

        // Find post by id from target user
        DatabaseManager.shared.getPost(
            with: postID
        ) { [weak self] post in
            DispatchQueue.main.async {
                guard post != nil else {
                    let alert = UIAlertController(
                        title: "Oops",
                        message: "We are unable to open this post.",
                        preferredStyle: .alert
                    )

                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    self?.present(alert, animated: true)
                    return
                }
//
//                let vc = PostViewController(post: post, owner: fromUsername)
//                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
