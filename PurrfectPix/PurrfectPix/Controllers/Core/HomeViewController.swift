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

    private let noPostLabel: UILabel = {
        let label = UILabel()
        label.text = "You have no post, tap Camera to create a post or check other pets at Explore! "
        label.textColor = .P1
        label.textAlignment = .center
//        label.isHidden = true
        return label
    }()

    // CollectionView for feed
    private var collectionView: UICollectionView?

    // Feed viewModels, two demensional array, each inner arry is a post or a section
    // 7 kinds of home feed cell enums on cell type models file
//    private var viewModels = [[HomeFeedCellType]]() {
//        didSet {
//            collectionView?.reloadData()
//        }
//    }

    // Notification observer
    private var observer: NSObjectProtocol?

    private var allPosts = [(post: Post, owner: String, viewModel:[HomeFeedCellType])]()

    // All post models
//    private var allPosts: [(post: Post, owner: String)] = []

    let dbFire = Firestore.firestore()

    override func viewDidLoad() {

        super.viewDidLoad()
        title = "PurrfectPix"
        view.backgroundColor = .systemBackground
        configureCollectionView()

        view.addSubview(noPostLabel)

        observer = NotificationCenter.default.addObserver(
            forName: .didPostNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.allPosts.removeAll() // clean all posts and fatch again  確認是不是allPosts就可以
//            self?.allPosts.viewModels.removeAll()
            self?.fetchPosts()
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPosts()
    }  // 有時候會出現兩次～

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }

    private func fetchPosts() {

        allPosts.removeAll() // fetch 之前先清除

        guard let username = AuthManager.shared.username else { return }

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

        allPosts = allPosts.sorted(by: { first, second in
            // 拿allPost的tuple 裡面的 timestamp cell來做排序
            var date1: Date?
            var date2: Date?
            first.viewModel.forEach {  type in
                switch type {
                case .timestamp(let vm):
                    date1 = vm.date
                default:
                    break
                }
            }
            second.viewModel.forEach { type in
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

        collectionView?.reloadData()
    }

    private func createViewModel(

        model: Post,
        userID: String,
        username: String,
        completion: @escaping (Bool) -> Void
    ) {
        // loading lottie play
        let animationView = self.setupAnimation(name: "890-loading-animation", mood: .autoReverse)
        animationView.play()

        StorageManager.shared.downloadURL(for: model) { postURL in
            StorageManager.shared.profilePictureURL(for: userID) { [weak self] profilePictureURL in

                guard let postUrl = postURL,
                      let userID = AuthManager.shared.userID

                else {
                          print("1. model.postUrlString\(model.postUrlString)")
                          print("2. profilePictureURL \(profilePictureURL)")
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

                        .actions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: model.likers.contains(userID))), // 這篇貼文的likers 裏面 有現在的userID, 就會是true

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

                // [(post: Post, owner: String, viewModel:[[HomeFeedCellType]])]()
                self?.allPosts.append((post: model, owner: username, viewModel: postData))

//                self?.viewModels.append(postData)// add to view model
                completion(true)

                // loading lottie stop
                animationView.stop()
                animationView.removeFromSuperview()

            }
        }
//        if viewModels.isEmpty {
//            noPostLabel.isHidden = false
//            collectionView.isHidden = true
//        }
//        else {
//            noPostLabelLabel.isHidden = true
//            noPostLabel.isHidden = false
//            collectionView.reloadData()
//        }

    }

    // MARK: collectionView datasource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return allPosts.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPosts[section].viewModel.count
    }

    let colors: [UIColor] = [
        .purple, .green, .lightGray, .blue, .yellow, .darkGray, .red
    ]

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // to show mock data
//        let cellType = viewModels[indexPath.section][indexPath.row]
        let cellType = allPosts[indexPath.section].viewModel[indexPath.row] // index out of range
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
            return cell

        case .actions(let viewModel):

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostActionsCollectionViewCell.identifer,
                for: indexPath
            ) as? PostActionsCollectionViewCell else {
                fatalError()
            }

            cell.delegate = self

            cell.configure(with: viewModel, index: indexPath.section)
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
            return cell

        case .caption(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostCaptionCollectionViewCell.identifer,
                for: indexPath
            ) as? PostCaptionCollectionViewCell else {
                fatalError()
            }

            cell.delegate = self
//            cell.contentView.backgroundColor = .lightGray
            cell.configure(with: viewModel)
            return cell

        case .comment(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CommentCollectionViewCell.identifier,
                for: indexPath
            ) as? CommentCollectionViewCell else {
                fatalError()
            }
//            cell.contentView.backgroundColor = .blue
            cell.configure(with: viewModel)
            return cell

        case .timestamp(let viewModel):

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostDateTimeCollectionViewCell.identifer,
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
    func posterCollectionViewCellDidTapMore(_ cell: PosterCollectionViewCell) {
        // upper right more meun

        let sheet = UIAlertController(
            title: "Post Actions",
            message: nil,
            preferredStyle: .actionSheet
        )

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        sheet.addAction(UIAlertAction(title: "Share Post", style: .default, handler: nil))

        sheet.addAction(UIAlertAction(title: "Report Post and Block User", style: .destructive, handler: { _ in}))

        present(sheet, animated: true)
    }

    func posterCollectionViewCellDidTapUsername(_ cell: PosterCollectionViewCell) {
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
        // 3 icons under picture, tap to like the post
        // call DB to update like state
//        let tupople = allPosts[index]

        guard let userID = AuthManager.shared.userID else { return }
        if allPosts[index].post.likers.contains(userID) {

            // todo: remove liker from post
            let likerIndex = allPosts[index].post.likers.firstIndex(of: userID)
            allPosts[index].post.likers.remove(at: likerIndex!)

            allPosts[index].viewModel[3] = .actions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: false))
            
        } else {
            allPosts[index].post.likers.append(userID)
            allPosts[index].viewModel[3] = .actions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: true))
        }

        DatabaseManager.shared.updateLikeState(
            state: isLiked ? .like : .unlike,
            postID: allPosts[index].post.postID) { success in
            guard success else {
                print("Failed to updated like state with heart icon")
                return
            }
                print("Updated likestate with heart icon success!")
        }

        self.collectionView?.reloadData()
        
        // create notification

    }

    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell, index: Int) {

        let postVC = PostViewController(singlePost:
                                            (post: allPosts[index].post,
                                             viewModel: allPosts[index].viewModel))
        //  還過不去ＱＱ
        // let postVC = PostViewController(singlePost: allPosts[index])
        // all post and single post 若為同型別
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

//        let listVC = ListViewController(type: .likers(usernames:
//        allPosts[index].post.likers))
//        listVC.title = "Liked by"
//        navigationController?.pushViewController(listVC, animated: true)

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
        let sectionHeight: CGFloat = 350 + view.width
        //view.width is the actual post size
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

//                let commentItem = NSCollectionLayoutItem(
//                    layoutSize: NSCollectionLayoutSize(
//                        widthDimension: .fractionalWidth(1),
//                        heightDimension: .absolute(80)
//                    )
//                )

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
                        heightDimension: .absolute(sectionHeight)
                    ),
                        subitems: [
                            posterItem,
                            petTagItem,
                            postItem,
                            actionsItem,
                            likeCountItem,
                            captionItem,
//                            commentItem,
                            timestampItem
                                  ]
                        )

                    // NSLayout Section
                    let section = NSCollectionLayoutSection(group: group)

                section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 8, trailing: 0)
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
