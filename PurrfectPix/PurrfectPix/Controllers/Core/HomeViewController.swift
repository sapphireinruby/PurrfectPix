//
//  ViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/16/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // CollectionView for feed
    private var collectionView: UICollectionView?

    // Feed viewModels, two demensional array, each inner arry is a post or a section
    // 7 kinds of home feed cell enums on cell type models file
    private var viewModels = [[HomeFeedCellType]]() {
        didSet {
            collectionView?.reloadData()
        }
    }

    // All post models
    private var allPosts: [(post: Post, owner: String)] = []
    // swiftlint:disable identifier_name
    let db = Firestore.firestore()

    override func viewDidLoad() {

        super.viewDidLoad()
        title = "PurrfectPix"
        view.backgroundColor = .systemBackground
        configureCollectionView()
        // username will edit later
//        UserDefaults.standard.setValue("wRWTOfxEaKtP8OSso4pB", forKey: "userID")
        fetchPosts()
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        fetchPosts()
//    }  // 有時候會出現兩次～


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }


    private func fetchPosts() {

//        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
//            return
//        }
//
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }

        guard let userID = AuthManager.shared.userID else { return }

        DatabaseManager.shared.posts(for: userID) { [weak self] result in
            // refresh the collectionView after all the asynchronous job is done

            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    let group = DispatchGroup()  

                    posts.forEach { model in
                        group.enter()

                        self?.createViewModel(
                            model: model,
                            userID: userID,
                            username: username,
                            completion: { success in
                            defer {
                                group.leave()
                            }
                            if !success {
                                print("failed to create viewModel")

                            }
                        })
                        group.notify(queue: .main) {
                            self?.collectionView?.reloadData()
                            self?.sortData()
                        }

                    }
                case . failure(let error):
                    print(error)
                }
            }

        }

    }

    private func sortData() {  // 目前有呼叫

        allPosts = allPosts.sorted(by: { first, second in
            let date1 = first.post.date
            let date2 = second.post.date
            return date1 > date2
        })

        viewModels = viewModels.sorted(by: { first, second in
            var date1: Date?
            var date2: Date?
            first.forEach { type in
                switch type {
                case .timestamp(let vm):
                    date1 = vm.date
                default:
                    break
                }
            }
            second.forEach { type in
                switch type {
                case .timestamp(let vm):
                    date2 = vm.date
                default:
                    break
                }
            }

            if let date1 = date1, let date2 = date2 {
                return date1 > date2
            }

            return false
        })

    }

    private func createViewModel(

        model: Post,
        userID: String,
        username: String,
        completion: @escaping (Bool) -> Void
    ) {

        // swiftlint:disable identifier_name
//        let UserID = "wRWTOfxEaKtP8OSso4pB"
//        let username = "perfect67"
        // MARK: 這裡未來要修改成動態

//        guard let currentUserID = AuthManager.shared.userID else { return }
        StorageManager.shared.downloadURL(for: model) { postURL in
            StorageManager.shared.profilePictureURL(for: userID) { [weak self] profilePictureURL in

                guard let postUrl = postURL,
                      let profilePhotoUrl = profilePictureURL else {
                          print("1. model.postUrlString\(model.postUrlString)")
                          print("2. profilePictureURL \(profilePictureURL)")
                            return
                }

                let postData: [HomeFeedCellType] = [
                    .poster(
                        viewModel: PosterCollectionViewCellViewModel(
                            username: model.username,
                            profilePictureURL: profilePhotoUrl
                        )
                    ),
                    
                    .petTag(
                        viewModel: PostPetTagCollectionViewCellViewModel(
                            petTag: model.petTag
                        )
                    ),

                    .post(
                        viewModel: PostCollectionViewCellViewModel(
                            postUrl: postUrl
                        )
                    ),

                    .actions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: false)),

                    .likeCount(viewModel: PostLikesCollectionViewCellViewModel(likers: [])),

                    .caption(
                        viewModel: PostCaptionCollectionViewCellViewModel(
                            username: model.username,
                            caption: model.caption)),

                    .timestamp(
                        viewModel: PostDatetimeCollectionViewCellViewModel(
                            date: DateFormatter.formatter.date(from: model.postedDate) ?? Date()
                        )
                    )
                ]
                self?.viewModels.append(postData) // add to view model
                completion(true)

            }
        }

    }

    // MARK: collectionView datasource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels[section].count
    }

    let colors: [UIColor] = [
        .purple, .green, .lightGray, .blue, .yellow, .darkGray, .red
    ]

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // to show mock data
        let cellType = viewModels[indexPath.section][indexPath.row]
        // section for the inner array

        switch cellType {

        case .poster(let viewModel):
        // to dequeue the right cell
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PosterCollectionViewCell.identifer,
                for: indexPath
            ) as? PosterCollectionViewCell else {
                fatalError()
            }

            cell.delegate = self  //delegate set up at cell class

            cell.configure(with: viewModel)
//            cell.contentView.backgroundColor = colors[indexPath.row]
            return cell

        case .petTag(let viewModel):

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostPetTagCollectionViewCell.identifer,
                for: indexPath
            ) as? PostPetTagCollectionViewCell else {
                fatalError()
            }

            cell.delegate = self
            
            cell.configure(with: viewModel)
//            cell.contentView.backgroundColor = colors[indexPath.row]
            return cell

        case .post(let viewModel):

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostCollectionViewCell.identifer,
                for: indexPath
            ) as? PostCollectionViewCell else {
                fatalError()
            }

            cell.delegate = self

            cell.configure(with: viewModel, index: indexPath.section)
//            cell.contentView.backgroundColor = colors[indexPath.row]
            return cell

        case .actions(let viewModel):

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostActionsCollectionViewCell.identifer,
                for: indexPath
            ) as? PostActionsCollectionViewCell else {
                fatalError()
            }

            cell.delegate = self

            cell.configure(with: viewModel)
//            cell.contentView.backgroundColor = colors[indexPath.row]
            return cell

        case .likeCount(let viewModel):

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostLikesCollectionViewCell.identifer,
                for: indexPath
            ) as? PostLikesCollectionViewCell else {
                fatalError()
            }

            cell.delegate = self

            cell.configure(with: viewModel)
//            cell.contentView.backgroundColor = colors[indexPath.row]
            return cell

        case .caption(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostCaptionCollectionViewCell.identifer,
                for: indexPath
            ) as? PostCaptionCollectionViewCell else {
                fatalError()
            }

            cell.delegate = self

            cell.configure(with: viewModel)
//            cell.contentView.backgroundColor = colors[indexPath.row]
            return cell

        case .timestamp(let viewModel):

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostDateTimeCollectionViewCell.identifer,
                for: indexPath
            ) as? PostDateTimeCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
//            cell.contentView.backgroundColor = colors[indexPath.row]
            return cell

        }

    }
}

// MARK: Cell delegate:

extension HomeViewController: PosterCollectionViewCellDelegate {
    func posterCollectionViewCellDidTapMore(_ cell: PosterCollectionViewCell) {
        // upper right more meun

        let sheet = UIAlertController(
            title: "Post Actions",
            message: nil,
            preferredStyle: .actionSheet
        )

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        sheet.addAction(UIAlertAction(title: "Share Post", style: .default, handler: nil))

        sheet.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { _ in}))

        present(sheet, animated: true)
    }

    func posterCollectionViewCellDidTapUsername(_ cell: PosterCollectionViewCell) {

//        let profileVC = ProfileViewController(user: User(userID: "userid2323", username: "morgan_likeplants", email: "morgan@fake.com", profilePic: "http://img.zcool.cn/community/01558c5987ef04a8012156039eb554.jpg@2o.jpg", followingUsers: ["perfect67", "elio_lovepuppy"], logInCount: 3))
//        navigationController?.pushViewController(profileVC, animated: true)
    }
}

extension HomeViewController: PostPetTagCollectionViewCellDelegate {
    func postPetTagCollectionViewCellDidTapPresentTagView(_ cell: PostPetTagCollectionViewCell) {
        // after tap, perform a search for the pet tags
    }

}

extension HomeViewController: PostCollectionViewCellDelegate {

    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell, index: Int) {
        // index to get the post
        let tuple = allPosts[index]
        DatabaseManager.shared.updateLikeState(
            // 出現錯誤  index outof range
            // can only like when tapped
            state: .like,
            postID: tuple.post.postID,
                                                                              owner: tuple.owner) { success in
            guard success else {
                return
            }
            print("Failed to like")
        }
    }
}

extension HomeViewController: PostActionsCollectionViewCellDelegate {

    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool) {
        // call DB to update like state

    }

    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell) {
//        let postVC = PostViewController(post: Post) // initiate a vc
//        postVC.title = "Post"
//        navigationController?.pushViewController(postVC, animated: true)
    }

    func postActionsCollectionViewCellDidTapShare(_ cell: PostActionsCollectionViewCell) {

        let shareVC = UIActivityViewController(activityItems: ["Sharing from PurrfectPix"], applicationActivities: [])
        present(shareVC, animated: true)

    }
}

extension HomeViewController: PostLikesCollectionViewCellDelegate {
    func postLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell) {

        let listVC = ListViewController()
        listVC.title = "Liked by"
        navigationController?.pushViewController(listVC, animated: true)

    }
}

extension HomeViewController: PostCaptionCollectionViewCellDelegate {
    func postCaptionCollectionViewCellDidTapCaptioon(_ cell: PostCaptionCollectionViewCell) {
        print("tapped caption")
    }
}

extension HomeViewController {

    func configureCollectionView() {

        // calulate the heigh dynamically for square
        let sectionHeight: CGFloat = 330 + view.width //view.width is the actual post size
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ -> NSCollectionLayoutSection? in

                    // cell for poster
                    // * cell for pet tag
                    // large cell for post
                    // actions cell
                    // like heart cell
                    // caption cell
                    // timestamp cell

                    // NSLayout item
                let posterItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(60)
                    )
                )

                let petTagItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(100)
                    )
                )

                let postItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalWidth(1)
                    )
                )

                let actionsItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(40)
                    )
                )

                let likeCountItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(40)
                    )
                )

                let captionItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(80)
                    )
                )

                let timestampItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(10)
                    )
                )

                    // NSLayout group
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(sectionHeight)
                    ),
                        subitems: [
                            posterItem,
                            petTagItem,
                            postItem,
                            actionsItem,
                            likeCountItem,
                            captionItem,
                            timestampItem
                                  ]
                        )

                    // NSLayout Section
                    let section = NSCollectionLayoutSection(group: group)

                section.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 0, bottom: 4, trailing: 0)
                // total 12 points between two sections
                    return section
                })
        )

        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self

        // register 7 cells
        collectionView.register(
            PosterCollectionViewCell.self,
            forCellWithReuseIdentifier: PosterCollectionViewCell.identifer
        )

        collectionView.register(
            PostPetTagCollectionViewCell.self,
            forCellWithReuseIdentifier: PostPetTagCollectionViewCell.identifer
        )

        collectionView.register(
            PostCollectionViewCell.self,
            forCellWithReuseIdentifier: PostCollectionViewCell.identifer
        )

        collectionView.register(
            PostActionsCollectionViewCell.self,
            forCellWithReuseIdentifier: PostActionsCollectionViewCell.identifer
        )

        collectionView.register(
            PostLikesCollectionViewCell.self,
            forCellWithReuseIdentifier: PostLikesCollectionViewCell.identifer
        )

        collectionView.register(
            PostCaptionCollectionViewCell.self,
            forCellWithReuseIdentifier: PostCaptionCollectionViewCell.identifer
        )

        collectionView.register(
            PostDateTimeCollectionViewCell.self,
            forCellWithReuseIdentifier: PostDateTimeCollectionViewCell.identifer
        )

        self.collectionView = collectionView  // configuring collectionView as it's own constance, and assign it to the global property
    }

}
