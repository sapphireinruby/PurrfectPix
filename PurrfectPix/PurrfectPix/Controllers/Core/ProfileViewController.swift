//
//  ProfileViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import UIKit

class ProfileViewController: UIViewController {

//    目前要調整的地方：改username and bio 後要更新畫面。
//    目前進來時還抓不到本人，所以無法再title 顯示username
//    算post數量錯誤

//    private let user: User

//    private var user: User? {
//        didSet {
//            if let user = user {
//                isCurrentUser = user.username == AuthManager.shared.username
//            } else {
//                isCurrentUser = false
//            }
//        }
//    }

    //        private let user: User
    //
    //        private var isCurrentUser: Bool {
//    return user.username == AuthManager.shared.username ?? ""
    //        }


    private var isCurrentUser: Bool {
        userID == AuthManager.shared.userID
    }
    // break point return true， 11/16 return false

    private var collectionView: UICollectionView?

    private var headerViewModel: ProfileHeaderViewModel? {

        didSet {
            collectionView?.reloadData()
        }

    }

    private var posts: [Post] = []

    private var observer: NSObjectProtocol?

    let userID: String

    init(userID: String) {
        self.userID = userID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchProfileInfo(userID: userID)
        title = "Profile"
//        title = user?.username.uppercased() ?? "Profile" // 無法顯示 username on title  因為無法正確辨識是不是本人
        view.backgroundColor = .systemBackground
        configureNavBar()
        configureCollectionView()

// NotificationCenter guard let VC 後打開
//        if isCurrentUser {
//            observer = NotificationCenter.default.addObserver(
//                forName: .didPostNotification,
//                object: nil,
//                queue: .main
//            ) { [weak self] _ in
//                self?.posts.removeAll()
//                self?.fetchProfileInfo(userID: self?.userID)
//            }
//        }

    }

    private func fetchProfileInfo(userID: String) {

        let group = DispatchGroup() // fetch all the info, then present it

        // Fetch Posts
        group.enter()
        DatabaseManager.shared.posts(for: userID) { [weak self] result in
            defer {
                group.leave()
            }

            switch result {
            case .success(let posts):
                self?.posts = posts
                self?.collectionView?.reloadData()
            case .failure:
                break
            }
        }

        // to store Profiel Header Info
        var profilePictureUrl = "" // 好像都沒存進去
        var buttonType: ProfileButtonType = .edit
        var username: String?
        var bio: String?

        var followerCount = 0
        var followingCount = 0
        var postCount = 0


        group.enter()

//        // hide container view
        DatabaseManager.shared.getUserInfo(userID: AuthManager.shared.userID ?? "") { userInfo in

            guard let userInfo = userInfo else { return }

            // 3 types of counts, following, followers, and posts
//            followerCount = userInfo.followerCount ?? 0
//            followingCount = userInfo.followingCount ?? 0
//            postCount = userInfo.postCount ?? 0

            // Bio, username
            username = userInfo.username ?? ""
            bio = userInfo.bio ?? "Introduce your pet to everyone!"

            // profilePictureURL
            profilePictureUrl = userInfo.profilePic ?? ""

            // set cache
            // for cache
            CacheUserInfo.shared.cache[userInfo.userID] = userInfo // closure 裡面要加self，但解開optional後就不用了

//            self.isCurrentUser = userInfo.userID == AuthManager.shared.userID

            self.headerViewModel = ProfileHeaderViewModel(
                profilePictureUrl: nil,
                followerCount: followerCount,
                followingICount: followingCount,
                postCount: postCount,
                buttonType: self.isCurrentUser ? .edit : .follow(isFollowing: true) ,
                username: userInfo.username ?? "Error",
                bio: userInfo.bio ?? "Error"
            )

        }

        // if not current user's profile, get follow state
//        if !isCurrentUser {
//            // need to get if the current user is following the perofile user account
//            group.enter()
//            DatabaseManager.shared.isFollowing(targetUserID: user.username) { isFollowing in
//                // isFollowing  function需要修改
//                defer {
//                    group.leave()
//                }
//                print(isFollowing)
//                buttonType = .follow(isFollowing: isFollowing)
//            }
//        }

//        group.notify(queue: .main) {
//            // swiftlint:disable line_length
//            self.headerViewModel = ProfileHeaderViewModel(
//                profilePictureUrl: URL(string: profilePictureUrl),
//                followerCount: 3,
//                followingICount: 4,
//                postCount: 7,
//                buttonType: buttonType,
//                username: username,
//                bio: bio
//            )
//            self.collectionView?.reloadData()
//        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }

    private func configureNavBar() {
        //  目前抓不到是否是本人 所以不會顯示
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
        return posts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionViewCell.identifier,
            for: indexPath
        ) as? PhotoCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: URL(string: posts[indexPath.row].postUrlString))
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

        headerView.delegate = self // change profile image
        headerView.countContainerView.postCountButton.setTitle("\(posts.count) Posts", for: .normal)
        return headerView
    }



    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let post = posts[indexPath.row]
        let vc = PostViewController(singlePost: (post, [HomeFeedCellType]()))
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension ProfileViewController: ProfileHeaderCollectionReusableViewDelegate {
    func profileHeaderCollectionReusableViewDidTapProfilePicture(_ header: ProfileHeaderCollectionReusableView) {

        guard isCurrentUser else {
            return
        }

        let sheet = UIAlertController(
            title: "Change Picture",
            message: "How about update a new photo with your pets?",
            preferredStyle: .actionSheet
        )

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in

            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.allowsEditing = true
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        sheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.allowsEditing = true
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        present(sheet, animated: true)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        StorageManager.shared.uploadProfilePicture(
            userID: userID,  //需要修改
            data: image.pngData()
        ) { [weak self] success in
            if success {
                guard let userID = self?.userID else { return }
                self?.headerViewModel = nil
                self?.posts = []
                self?.fetchProfileInfo(userID: userID)
            }
        }
    }
}

extension ProfileViewController: ProfileHeaderCountViewDelegate {
    func profileHeaderCountViewDidTapFollowers(_ containerView: ProfileHeaderCountView) {

    }

    func profileHeaderCountViewDidTapFollowing(_ containerView: ProfileHeaderCountView) {

    }

    func profileHeaderCountViewDidTapPosts(_ containerView: ProfileHeaderCountView) {
        guard posts.count >= 18 else {
            return
        }
        collectionView?.setContentOffset(CGPoint(x: 0, y: view.width * 0.4),
                                         animated: true)
    }

    func profileHeaderCountViewDidTapEditProfile(_ containerView: ProfileHeaderCountView) {

        let vc = EditProfileViewController()

        vc.completion = { [weak self] in
            // refetch/reload hearder info
            guard let userID = self?.userID else { return }
            self?.headerViewModel = nil
            self?.fetchProfileInfo(userID: userID)
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
