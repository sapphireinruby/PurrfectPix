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
    // calulate the heigh dynamically for square
    private var collectionView: UICollectionView?

    // Feed viewModels
    private var viewModels = [[HomeFeedCellType]]() {
        didSet {
            collectionView?.reloadData()
        }
    }

    // All post models
    private var allPosts: [(post: Post, owner: String)] = []

    let db = Firestore.firestore()

    override func viewDidLoad() {

//
//        db.collection("posts").getDocuments { snapshot, error in
//
//            if let  error = error {
//                print (error)
//
//            }else{
//
//                guard let snapshot = snapshot else { return }
//                    var posts = [Post]()
//                    snapshot.documents.forEach({ document in
//
//                        do {
//                            let post =  try document.data(as: Post.self)
//                            guard let post = post else {return}
//                            posts.append(post)
//                        } catch {
//
//                        }
//                    })
//                    self.createViewModel(model: posts, username: "Amber67") { result in
//                    }
//            }
//        }
//            let result = Result {
//              try document?.data(as: Post.self)
//            }



//            switch result {
//            case .success(let post):
//                if let post = post {
//                    self.createViewModel(model: post, username: "Amber67") { result in
//
//                    }
//
//                } else {
//                    // A nil value was successfully initialized from the DocumentSnapshot,
//                    // or the DocumentSnapshot was nil.
//                    print("Document does not exist")
//                }
//            case .failure(let error):
//                // A `City` value could not be initialized from the DocumentSnapshot.
//                print("Error decoding city: \(error)")
//            }


        super.viewDidLoad()
        title = "PurrfectPix"
        view.backgroundColor = .systemBackground
//        configureCollectionView()
//        fetchPosts()
        UserDefaults.standard.setValue("wRWTOfxEaKtP8OSso4pB", forKey: "userID")
        // 也許key該換成username
    }

    override func viewWillAppear(_ animated: Bool) {

        viewModels = [[HomeFeedCellType]]()
        db.collection("posts").getDocuments { snapshot, error in

            if let  error = error {
                print(error)

            } else {

                guard let snapshot = snapshot else { return }
                    var posts = [Post]()
                    snapshot.documents.forEach({ document in

                        do {
                            let post =  try document.data(as: Post.self)
                            guard let post = post else {return}
                            posts.append(post)
                        } catch {

                        }
                    })
                    self.createViewModel(model: posts, username: "Amber67") { result in
                    }
            }
    }

        configureCollectionView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }

//    private func fetchPosts() {
//
//        guard let username = UserDefaults.standard.string(forKey: "username") else {
//            return
//        }
//
//        let userGroup = DispatchGroup()
//        userGroup.enter()
//
//        var allPosts: [(post: Post, owner: String)] = []
//
//        // refresh the collectionView after all the asynchronous job is done
//        DatabaseManager.shared.following(for: username) { usernames in
//            defer {
//                userGroup.leave()
//            }
//
//            let users = usernames + [username]
//
//            for current in users {
//
//                userGroup.enter()
//
//                DatabaseManager.shared.posts(for: current) { result in
//                    DispatchQueue.main.async {
//
//                        defer {
//                            userGroup.leave()
//                        }
//
//                        switch result {
//
//                        case .success(let posts):
//                            allPosts.append(contentsOf: posts.compactMap({
//                                (post: $0, owner: current)
//                            }))
//                            print("\n\n\n Posts: \(posts.count)")
//
//                        case .failure:
//                            break
//                        }
//                    }
//                }
//            }
//        }
//
//        userGroup.notify(queue: .main) {
//            let group = DispatchGroup()
//            self.allPosts = allPosts
//            allPosts.forEach { model in
//                group.enter()
//                self.createViewModel(
//                    model: model.post,
//                    username: model.owner,
//                    completion: { success in
//                        defer {
//                            group.leave()
//                        }
//                        if !success {
//                            print("failed to create VM")
//                        }
//                    }
//                )
//            }
//
//            group.notify(queue: .main) {
//                self.sortData()
//                self.collectionView?.reloadData()
//            }
//        }
//    }

    private func sortData() {
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

        model: [Post],
        username: String,
        completion: @escaping (Bool) -> Void
    ) {
//        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        let currentUsername = "Amber67"


        for model in model {
            StorageManager.shared.profilePictureURL(for: currentUsername) { [weak self] profilePictureURL in

                print("1\(model.postUrlString)")
                print("2\(profilePictureURL)")
                guard let postUrl = URL(string: model.postUrlString),
                      let profilePhotoUrl = profilePictureURL else {
                    return
                }

                let isLiked = model.likers.contains(currentUsername)

                let postData: [HomeFeedCellType] = [
                    .poster(
                        viewModel: PosterCollectionViewCellViewModel(
                            username: username,
                            profilePictureURL: profilePhotoUrl
                        )
                    ),
                    .petTag(
                        viewModel: PostPetTagCollectionViewCellViewModel(petTag: "cat")
                    ),

                    .post(
                        viewModel: PostCollectionViewCellViewModel(
                            postUrl: postUrl
                        )
                    ),
                    .actions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: isLiked)),
                    .likeCount(viewModel: PostLikesCollectionViewCellViewModel(likers: model.likers)),
                    .caption(
                        viewModel: PostCaptionCollectionViewCellViewModel(
                            username: username,
                            caption: model.caption)),
                    .timestamp(
                        viewModel: PostDatetimeCollectionViewCellViewModel(
                            date: DateFormatter.formatter.date(from: model.postedDate) ?? Date()
                        )
                    )
                ]
                self?.viewModels.append(postData)
                completion(true)
            }
        }
    }

    // collectionView

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels[section].count
    }

    let colors: [UIColor] = [
        .purple,
        .green,
        .lightGray,
        .blue,
        .yellow,
        .darkGray,
        .red
    ]

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // to show mock data
        let cellType = viewModels[indexPath.section][indexPath.row]

        switch cellType {

        case .poster(let viewModel):

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

            cell.configure(with: viewModel)
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

extension HomeViewController: PostLikesCollectionViewCellDelegate {
    func postLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell) {

        let vc = ListViewController() // initiate a vc
        vc.title = "Liked by / 被誰大心"
        navigationController?.pushViewController(vc, animated: true)


    }
}

extension HomeViewController: PostCaptionCollectionViewCellDelegate {
    func postCaptionCollectionViewCellDidTapCaptioon(_ cell: PostCaptionCollectionViewCell) {
        print("tapped caption")
    }
}

extension HomeViewController: PostActionsCollectionViewCellDelegate {
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool) {
        // call DB to update like state
    }

    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell) {
         let vc = PostViewController()
        vc.title = "Post"
        navigationController?.pushViewController(vc, animated: true)
    }

    func postActionsCollectionViewCellDidTapShare(_ cell: PostActionsCollectionViewCell) {

        let vc = UIActivityViewController(activityItems: ["Sharing from PurrfectPix"], applicationActivities: [])
        present(vc, animated: true)

    }
}


extension HomeViewController: PostCollectionViewCellDelegate {
    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell) {
        print("tapped to like")
    }
}

extension HomeViewController: PosterCollectionViewCellDelegate {
    func posterCollectionViewCellDidTapMore(_ cell: PosterCollectionViewCell) {
        // upper right three dot meun

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
//        let vc = ProfileViewController(user: User(userID: "userid2323", username: "morgan_likeplants", email: "morgan@fake.com"))
    }
}


extension HomeViewController {

    func configureCollectionView() {

        let sectionHeight: CGFloat = 240 + view.width
//        let sectionHeight: CGFloat = 240 + view.width
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

                    // item
                let posterItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(60)
                    )
                )

                let petTagItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(60)
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
                        heightDimension: .absolute(60)
                    )
                )

                let timestampItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(40)
                    )
                )

                    // group
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

                    // cell for poster
                    // * cell for pet tag
                    // large cell for post
                    // action cell
                    // like heart cell
                    // caption cell
                    // timestamp cell

                    // section
                    let section = NSCollectionLayoutSection(group: group)

                section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 0, bottom: 10, trailing: 0)

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

        self.collectionView = collectionView
    }

}
