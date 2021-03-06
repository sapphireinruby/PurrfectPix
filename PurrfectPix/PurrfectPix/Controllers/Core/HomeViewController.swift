//
//  ViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/16/21.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private let noPostLabel: UILabel = {
        let label = UILabel()
        label.text = "If you have no post yet, \nTap Camera to create your post \nor check other pets at Explore!"
        label.textColor = .P1
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.isHidden = false
        return label
    }()

    // CollectionView for feed
    private var collectionView: UICollectionView?

    // Feed viewModels, two dimensional array, each inner array is a post or a section
    // 7 kinds of home feed cell enums on cell type models file
    //    private var viewModels = [[HomeFeedCellType]]() {
    //        didSet {
    //            collectionView?.reloadData()
    //        }
    //    }

    private var allPosts = [(post: Post, owner: String, viewModel:[HomeFeedCellType])]()

    override func viewDidLoad() {

        super.viewDidLoad()
        title = "PurrfectPix"
        view.backgroundColor = .systemBackground
        configureCollectionView()
        fetchPosts()

        view.addSubview(noPostLabel)

        NotificationCenter.default.addObserver(
            forName: .didPostNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.fetchPosts()
        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noPostLabel.center = view.center
        noPostLabel.sizeToFit()
        collectionView?.frame = view.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func fetchPosts() {

        allPosts.removeAll()
        // remove all data, to make screen empty to avoid scroll and crash due to vm created incomplete
        collectionView?.reloadData()

        guard AuthManager.shared.username != nil else { return }

        guard let userID = AuthManager.shared.userID else { return }

        DatabaseManager.shared.following(for: userID) { posts in

            let group = DispatchGroup()
            var count = 0
            posts.forEach { model in
                print("group enter \(count)")
                group.enter()
                count += 1

                self.createViewModel(
                    model: model,
                    userID: model.userID,
                    username: model.username,
                    completion: { success in
                        defer {
                            print("group leave \(count)")
                            group.leave()
                        }
                        if !success {
                            print("failed to create viewModel")

                        }
                    })
            }
            group.notify(queue: .main) {
                self.sortData()
            }
        }
    }

    private func sortData() {

        allPosts = allPosts.sorted(by: { first, second in
            let date1 = first.post.date
            let date2 = second.post.date
            return date1 > date2
        })

        allPosts = allPosts.sorted(by: { first, second in

            var date1: Date?
            var date2: Date?
            first.viewModel.forEach {  type in
                switch type {
                case .timestamp(let viewModel):
                    date1 = viewModel.date
                default:
                    break
                }
            }
            second.viewModel.forEach { type in
                switch type {
                case .timestamp(let viewModel):
                    date2 = viewModel.date

                default:
                    break
                }
            }

            if let date1 = date1, let date2 = date2 {
                return date1 > date2
            }

            return false
        })

        if allPosts.isEmpty {
            noPostLabel.isHidden = false
        } else {
            noPostLabel.isHidden = true
        }
        collectionView?.reloadData()
    }

    private func createViewModel(

        model: Post,
        userID: String,
        username: String,
        completion: @escaping (Bool) -> Void
    ) {
        // loading Lottie play
        let animationView = self.createAnimation(name: "890-loading-animation", mood: .autoReverse)
        animationView.play()

        StorageManager.shared.downloadURL(for: model) { postURL in
            StorageManager.shared.profilePictureURL(for: userID) { [weak self] profilePictureURL in

                guard let postUrl = postURL,
                      let userID = AuthManager.shared.userID

                else {
                    print("1. model.postUrlString\(model.postUrlString)")
                    print("2. profilePictureURL \(profilePictureURL)")
                    completion(false)

                    return
                }

                let postData: [HomeFeedCellType] = [
                    .poster(
                        viewModel: PosterCollectionViewCellViewModel(
                            username: model.username,
                            profilePictureURL: profilePictureURL ?? nil
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

                        .actions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: model.likers.contains(userID))),

                        .likeCount(viewModel: PostLikesCollectionViewCellViewModel(likers: model.likers)),

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

                self?.allPosts.append((post: model, owner: username, viewModel: postData))

                completion(true)

                // loading Lottie stop
                animationView.stop()
                animationView.removeFromSuperview()

            }

        }

    }

    // MARK: collectionView datasource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return allPosts.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPosts[section].viewModel.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cellType = allPosts[indexPath.section].viewModel[indexPath.row]
        // section for the inner array

        switch cellType {

        case .poster(let viewModel):
            // to dequeue the right cell
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PosterCollectionViewCell.identifier,
                for: indexPath
            ) as? PosterCollectionViewCell else {
                fatalError()
            }

            cell.delegate = self  // delegate set up at cell class

            cell.configure(with: viewModel, index: indexPath.section)
            return cell

        case .petTag(let viewModel):

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostPetTagCollectionViewCell.identifier,
                for: indexPath
            ) as? PostPetTagCollectionViewCell else {
                fatalError()
            }

            cell.delegate = self
            
            cell.configure(with: viewModel)
            return cell

        case .post(let viewModel):

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostCollectionViewCell.identifier,
                for: indexPath
            ) as? PostCollectionViewCell else {
                fatalError()
            }

            cell.delegate = self

            cell.configure(with: viewModel, index: indexPath.section)
            return cell

        case .actions(let viewModel):

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostActionsCollectionViewCell.identifier,
                for: indexPath
            ) as? PostActionsCollectionViewCell else {
                fatalError()
            }

            cell.delegate = self

            cell.configure(with: viewModel, index: indexPath.section)
            return cell

        case .likeCount(let viewModel):

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostLikesCollectionViewCell.identifier,
                for: indexPath
            ) as? PostLikesCollectionViewCell else {
                fatalError()
            }

            cell.delegate = self

            cell.configure(with: viewModel)
            return cell

        case .caption(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostCaptionCollectionViewCell.identifier,
                for: indexPath
            ) as? PostCaptionCollectionViewCell else {
                fatalError()
            }

            cell.delegate = self

            cell.configure(with: viewModel, index: indexPath.section)
            return cell

        case .comment(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CommentCollectionViewCell.identifier,
                for: indexPath
            ) as? CommentCollectionViewCell else {
                fatalError()
            }

            cell.configure(with: viewModel, index: indexPath.section)
            return cell

        case .timestamp(let viewModel):

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostDateTimeCollectionViewCell.identifier,
                for: indexPath
            ) as? PostDateTimeCollectionViewCell else {
                fatalError()

            }
            cell.configure(with: viewModel)
            return cell
        }
    }
}

// MARK: Cell delegate:

extension HomeViewController: PosterCollectionViewCellDelegate {
    func posterCollectionViewCellDidTapMore(_ cell: PosterCollectionViewCell, index: Int) {

        let currentUserID = AuthManager.shared.userID
        let targetUserID = allPosts[index].post.userID

        let sheet = UIAlertController(
            title: "Post Actions",
            message: nil,
            preferredStyle: .actionSheet
        )

        if currentUserID == targetUserID {
            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            sheet.addAction(UIAlertAction(title: "Share Post", style: .default, handler: nil))

            if let popoverController = sheet.popoverPresentationController {

                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }

        } else {
            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            sheet.addAction(UIAlertAction(title: "Share Post", style: .default, handler: nil))
            sheet.addAction(UIAlertAction(title: "Report Post and Block User", style: .destructive, handler: { [weak self] _ in
                guard let targetUserID = self?.allPosts[index].post.userID else { return }

                DatabaseManager.shared.setBlockList(for: targetUserID) { success in
                    if success {
                        print("Add user \(targetUserID) to block list")
                    }
                }
            }))
            if let popoverController = sheet.popoverPresentationController {

                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        
        present(sheet, animated: true)
    }

    func posterCollectionViewCellDidTapUsername(_ cell: PosterCollectionViewCell, index: Int) {

        let userID = allPosts[index].post.userID

        let vcProfile = ProfileViewController(userID: userID)
        navigationController?.pushViewController(vcProfile, animated: true)

    }

    func posterCollectionViewCellDidTapUserPic(_ cell: PosterCollectionViewCell, index: Int) {

        let userID = allPosts[index].post.userID

        let vcProfile = ProfileViewController(userID: userID)
        navigationController?.pushViewController(vcProfile, animated: true)

    }
}

extension HomeViewController: PostPetTagCollectionViewCellDelegate {
    func postPetTagCollectionViewCellDidTapPresentTagView(_ cell: PostPetTagCollectionViewCell) {
        // after tap, perform a search for the pet tags
    }

}

extension HomeViewController: PostCollectionViewCellDelegate {

    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell, index: Int) {
        // post picture, tap to like the post
        // index to get the post
        // create notification
        guard let userID = AuthManager.shared.userID else { return }
        if allPosts[index].post.likers.contains(userID) {

        } else {
            allPosts[index].post.likers.append(userID)
            let post = allPosts[index].post
            allPosts[index].viewModel[3] = .actions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: post.likers.contains(userID)))
        }

        let likers = allPosts[index].post.likers
        allPosts[index].viewModel[4] = .likeCount(viewModel: PostLikesCollectionViewCellViewModel(likers: likers))

        DatabaseManager.shared.updateLikeState(
            state: .like,
            postID: allPosts[index].post.postID) { success in
                guard success else {
                    print("Failed to like from post picture")

                    return
                }
                print("Like post from post picture success!")
            }

        self.collectionView?.reloadData()
    }
}

extension HomeViewController: PostActionsCollectionViewCellDelegate {

    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool, index: Int) {
        // 3 icons under picture, tap to like the post, call DB to update like state

        guard let userID = AuthManager.shared.userID else { return }
        if allPosts[index].post.likers.contains(userID) {

            let likerIndex = allPosts[index].post.likers.firstIndex(of: userID)
            allPosts[index].post.likers.remove(at: likerIndex!)

            allPosts[index].viewModel[3] = .actions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: false))

        } else {
            allPosts[index].post.likers.append(userID)
            allPosts[index].viewModel[3] = .actions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: true))
        }

        let likers = allPosts[index].post.likers
        allPosts[index].viewModel[4] = .likeCount(viewModel: PostLikesCollectionViewCellViewModel(likers: likers))

        DatabaseManager.shared.updateLikeState(
            state: isLiked ? .like : .unlike,
            postID: allPosts[index].post.postID) { success in
                guard success else {
                    print("Failed to updated like state with heart icon")
                    return
                }
                print("Updated like state with heart icon success!")
            }

        self.collectionView?.reloadData()
        
        // create notification in future

    }

    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell, index: Int) {

        let postVC = PostViewController(singlePost:
                                            (post: allPosts[index].post,
                                             viewModel: allPosts[index].viewModel))
        postVC.title = "Post"
        navigationController?.pushViewController(postVC, animated: true)
    }

    func postActionsCollectionViewCellDidTapShare(_ cell: PostActionsCollectionViewCell) {

        let shareVC = UIActivityViewController(activityItems: ["Sharing from PurrfectPix"], applicationActivities: [])
        present(shareVC, animated: true)

    }
}

extension HomeViewController: PostLikesCollectionViewCellDelegate {

    func postLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell, index: Int) {

        var count = allPosts[index].post.likers.count

                self.collectionView?.reloadData()
    }
}

extension HomeViewController: PostCaptionCollectionViewCellDelegate {
    func postCaptionCollectionViewCellDidTapCaption(_ cell: PostCaptionCollectionViewCell, index: Int) {
        print("tapped caption")

        let postVC = PostViewController(singlePost:
                                            (post: allPosts[index].post,
                                             viewModel: allPosts[index].viewModel))
        postVC.title = "Post"
        navigationController?.pushViewController(postVC, animated: true)
        
    }
}

extension HomeViewController {

    func configureCollectionView() {

        // calculate the heigh dynamically for square with device width
        // view.width is the actual post size
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ -> NSCollectionLayoutSection? in

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
                        heightDimension: .estimated(80)
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
                        heightDimension: .absolute(50)
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
                        heightDimension: .estimated(80)
                    )
                )

                let timestampItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(30)
                    )
                )

                // NSLayout group
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
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
            forCellWithReuseIdentifier: PosterCollectionViewCell.identifier
        )

        collectionView.register(
            PostPetTagCollectionViewCell.self,
            forCellWithReuseIdentifier: PostPetTagCollectionViewCell.identifier
        )

        collectionView.register(
            PostCollectionViewCell.self,
            forCellWithReuseIdentifier: PostCollectionViewCell.identifier
        )

        collectionView.register(
            PostActionsCollectionViewCell.self,
            forCellWithReuseIdentifier: PostActionsCollectionViewCell.identifier
        )

        collectionView.register(
            PostLikesCollectionViewCell.self,
            forCellWithReuseIdentifier: PostLikesCollectionViewCell.identifier
        )

        collectionView.register(
            PostCaptionCollectionViewCell.self,
            forCellWithReuseIdentifier: PostCaptionCollectionViewCell.identifier
        )

        collectionView.register(
            PostDateTimeCollectionViewCell.self,
            forCellWithReuseIdentifier: PostDateTimeCollectionViewCell.identifier
        )

        self.collectionView = collectionView  // configuring collectionView as it's own constance, and assign it to the global property
    }
}
