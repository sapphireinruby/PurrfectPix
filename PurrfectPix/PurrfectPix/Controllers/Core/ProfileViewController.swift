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
        return user.username == AuthManager.shared.username ?? ""
    } // break point return true

    private var collectionView: UICollectionView?

    private var headerViewModel: ProfileHeaderViewModel?

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
        configureNavBar()
        configureCollectionView()
        fetchProfileInfo()
    }

    private func fetchProfileInfo() {
//        let username = user.username
        // mock data
        headerViewModel = ProfileHeaderViewModel(
            profilePictureUrl: nil,
            followerCount: 23,
            followingICount: 17,
            postCount: 16,
            buttonType: self.isCurrentUser ? .edit : .follow(isFollowing: true) ,
            username: "Amberlala",
            bio: "Check out me and my puppy ZumZum"
        )

        // to store Profiel Header Info
        var profilePictureUrl = "" // 好像都沒存進去
        var buttonType: ProfileButtonType = .edit
        var username: String?
        var bio: String?

        var followerCount = 0
        var followingCount = 0
        var postCount = 0

        let group = DispatchGroup() // fet all the info, then present it
        group.enter()

//        // hide container view
        DatabaseManager.shared.getUserInfo(userID: user.userID) { userInfo in
            // 3 types of counts, following, followers, and posts
            followerCount = userInfo?.followerCount ?? 0
            followingCount = userInfo?.followingCount ?? 0
            postCount = userInfo?.postCount ?? 0

            // Bio, username
            username = userInfo?.username ?? ""
            bio = userInfo?.bio ?? "Introduce your pet to everyone!"

            // profilePictureURL
            profilePictureUrl = userInfo?.profilePic ?? ""
        }


        // if not current user's profile, get follow state
        if !isCurrentUser{
            // need to get if the current user is following the perofile user account
            group.enter()
            DatabaseManager.shared.isFollowing(targetUserID: user.username) { isFollowing in
                // isFollowing  function需要修改
                defer {
                    group.leave()
                }
                print(isFollowing)
                buttonType = .follow(isFollowing: isFollowing)
            }
        }

        group.notify(queue: .main) {
            // swiftlint:disable line_length
            self.headerViewModel = ProfileHeaderViewModel(
                profilePictureUrl: URL(string: profilePictureUrl),
                followerCount: 3,
                followingICount: 4,
                postCount: 7,
                buttonType: buttonType,
                username: username,
                bio: bio
            )
            self.collectionView?.reloadData()
        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }

    private func configureNavBar() {
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
extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionViewCell.identifier,
            for: indexPath
        ) as? PhotoCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: UIImage(named: "test"))
        return cell
    }

    // register reuseable header cell
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier,
                for: indexPath
              ) as? ProfileHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        if let viewModel = headerViewModel {
            headerView.configure(with: viewModel)
            headerView.countContainerView.delegate = self
        }

        let viewModel = ProfileHeaderViewModel(
            profilePictureUrl: nil,
            followerCount: 23,
            followingICount: 17,
            postCount: 6,
            buttonType: self.isCurrentUser ? .edit : .follow(isFollowing: true),
            username: "Elionono",
            bio: "Check out my cute puppy Dodo"
        )

        return headerView
    }



    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
//        let post = posts[indexPath.row]
//        let vc = PostViewController(post: post)
//        navigationController?.pushViewController(vc, animated: true)
    }

}

extension ProfileViewController: ProfileHeaderCountViewDelegate {
    func profileHeaderCountViewDidTapFollowers(_ containerView: ProfileHeaderCountView) {

    }

    func profileHeaderCountViewDidTapFollowing(_ containerView: ProfileHeaderCountView) {

    }

    func profileHeaderCountViewDidTapPosts(_ containerView: ProfileHeaderCountView) {

    }

    func profileHeaderCountViewDidTapEditProfile(_ containerView: ProfileHeaderCountView) {

        let vc = EditProfileViewController()
        vc.completion = { [weak self] in
            // refetch/reload hearder info
            self?.headerViewModel = nil
            self?.fetchProfileInfo()
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)

    }

    func profileHeaderCountViewDidTapFollow(_ containerView: ProfileHeaderCountView) {

    }

    func profileHeaderCountViewDidTapUnFollow(_ containerView: ProfileHeaderCountView) {

    }


}

extension ProfileViewController{
    func configureCollectionView() {

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ -> NSCollectionLayoutSection? in

                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))

                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalWidth(0.33)
                    ),
                    subitem: item,
                    count: 3
                )

                let section = NSCollectionLayoutSection(group: group)

                section.boundarySupplementaryItems = [
                    NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalWidth(0.66)
                        ),
                        elementKind: UICollectionView.elementKindSectionHeader,
                        alignment: .top
                    )
                ]

                return section
            })
        )
        collectionView.register(PhotoCollectionViewCell.self,
                                forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)

        collectionView.register(
            ProfileHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier
        )

        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)

        self.collectionView = collectionView

    }

}
