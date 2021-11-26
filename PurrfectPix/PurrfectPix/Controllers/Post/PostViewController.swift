//
//  PostViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
import FirebaseFirestore
import UIKit
import CoreAudio
import AVFoundation
import StoreKit

class PostViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private var collectionView: UICollectionView?

    private var singlePost: (post: Post, viewModel: [HomeFeedCellType])

    // for comment
    private let commentBarView = CommentBarView()
    private var observer: NSObjectProtocol?
    private var hideObserver: NSObjectProtocol?

    // for comment keyboard
    private var bgView = UIView()

    // MARK: - Init

    init(singlePost: (post: Post, viewModel: [HomeFeedCellType])) {
        self.singlePost = singlePost
        super.init(nibName: nil, bundle: nil)

        // hide tab bar
        hidesBottomBarWhenPushed = true

    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    let dbFire = Firestore.firestore()

    // MARK: - Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()
        title = "Post"
        view.backgroundColor = .systemBackground
        configureCollectionView()
        fetchPost(postID: singlePost.post.postID)

        // for comment
        view.addSubview(commentBarView)
        view.addSubview(bgView)
        bgView.backgroundColor = .systemBackground
        commentBarView.delegate = self
        //        observeKeyboardChange()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds

        // comment
        commentBarView.frame = CGRect(
            x: 0,
            //            y: view.height-view.safeAreaInsets.bottom-60,
            y: view.height-view.safeAreaInsets.bottom - 72,
            width: view.width,
            height: 72)

        // comment
        bgView.frame = CGRect(
            x: 0,
            y: view.height-view.safeAreaInsets.bottom,
            //            y: view.height-view.safeAreaInsets.bottom - 72,
            width: view.width,
            height: 72)
    }

    // for comment keyboard
    private func observeKeyboardChange() {
        observer = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let userInfo = notification.userInfo,
                  let height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
                      return
                  }
            UIView.animate(withDuration: 0.2) {
                self.commentBarView.frame = CGRect(
                    x: 0,
                    y: self.view.height-60-height,
                    width: self.view.width,
                    height: 70
                )
            }
        }

        hideObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            UIView.animate(withDuration: 0.2) {
                self.commentBarView.frame = CGRect(
                    x: 0,
                    y: self.view.height-self.view.safeAreaInsets.bottom-70,
                    width: self.view.width,
                    height: 70
                )
            }
        }
    }

    private func fetchPost(postID: String) {


        createViewModel(
            model: singlePost.post,
            userID: singlePost.post.userID,
            username: singlePost.post.username,
            completion: { success in
                guard success else {
                    print("failed to create post")
                    return
                }
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        )
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

                guard let strongSelf = self,
                      let postUrl = URL(string: model.postUrlString),
                      let userID = AuthManager.shared.userID
                else {
                    completion(false)
                    print("1. model.postUrlString\(model.postUrlString)")
                    print("2. profilePictureURL \(String(describing: profilePictureURL))")
                    return
                }

                DatabaseManager.shared.getComments(
                    postID: strongSelf.singlePost.post.postID
                ) { result in

                    var postData: [HomeFeedCellType] = [
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
                                    caption: model.caption))
                    ]

                    postData.append(
                        .timestamp(
                            viewModel: PostDatetimeCollectionViewCellViewModel(
                                date: DateFormatter.formatter.date(from: model.postedDate) ?? Date()
                            )
                        )

                    )

                    switch result {

                    case .success(let comments):

                        comments.forEach { comment in
                            postData.append(
                                .comment(viewModel: comment)
                            )
                        }

                    case .failure(_): break
                    }

                    // [(post: Post, owner: String, viewModel:[[HomeFeedCellType]])]()
                    guard let self = self else { return }
                    self.singlePost.viewModel = postData
                    completion(true)

                    // loading lottie stop
                    animationView.stop()
                    animationView.removeFromSuperview()

                }

            }
        }

    }

    // MARK: collectionView datasource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        return allPosts[section].viewModel.count

        return singlePost.viewModel.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = singlePost.viewModel[indexPath.row]

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
            cell.configure(with: viewModel, index: indexPath.section)
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

        case .comment(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CommentCollectionViewCell.identifier,
                for: indexPath
            ) as? CommentCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell

        }
    }
}

// comment Bar
extension PostViewController: CommentBarViewDelegate {
    func commentBarViewDidTapDone(_ commentBarView: CommentBarView, withText text: String) {
        guard let currentUserID = AuthManager.shared.userID,
              let currentUsername = AuthManager.shared.username
        else { return }

        let comment = Comment(
            userID: currentUserID,
            username: currentUsername,
            comment: text,
            dateString: String.date(from: Date()) ?? ""
        )

        DatabaseManager.shared.createComments(
            comment: comment,
            postID: singlePost.post.postID,
            userID: currentUserID
        ) { success in
            DispatchQueue.main.async {
                //                self.collectionView?.reloadData() // 沒有成功
                guard success else {
                    return
                }
            }
        }

//        var newInd = singlePost.viewModel.count
//        singlePost.viewModel[newInd] = .comment(viewModel: comment)
        // index是對的 但是無法生成cell
        singlePost.post.comments?.append(comment)
        singlePost.viewModel[7] = .comment(viewModel: comment)
        // 會一直重複覆蓋 第一筆留言 若沒有留言的會index out of rabge
        collectionView?.reloadData()
    }
}
// MARK: Cell delegate:

extension PostViewController: PosterCollectionViewCellDelegate {
    func posterCollectionViewCellDidTapMore(_ cell: PosterCollectionViewCell, index: Int) {
        let sheet = UIAlertController(
            title: "Post Actions",
            message: nil,
            preferredStyle: .actionSheet
        )

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        sheet.addAction(UIAlertAction(title: "Share Post", style: .default, handler: nil))

        sheet.addAction(UIAlertAction(title: "Report Post and Block User", style: .destructive, handler: { [weak self] _ in
            guard let targetUserID = self?.singlePost.post.userID else { return }

            DatabaseManager.shared.setBlockList(for: targetUserID) { success in
                if success {
                    print("Add user \(targetUserID) to block list")
                }
            }
        }))

        present(sheet, animated: true)
    }

    func posterCollectionViewCellDidTapUsername(_ cell: PosterCollectionViewCell, index: Int) {

        let userID = singlePost.post.userID

        let vcProfile = ProfileViewController(userID: userID)
        navigationController?.pushViewController(vcProfile, animated: true)

    }

    func posterCollectionViewCellDidTapUserPic(_ cell: PosterCollectionViewCell, index: Int) {

        let userID = singlePost.post.userID

        let vcProfile = ProfileViewController(userID: userID)
        navigationController?.pushViewController(vcProfile, animated: true)

    }
}

extension PostViewController: PostPetTagCollectionViewCellDelegate {
    func postPetTagCollectionViewCellDidTapPresentTagView(_ cell: PostPetTagCollectionViewCell) {
        // after tap, perform a search for the pet tags
    }

}

extension PostViewController: PostCollectionViewCellDelegate {

    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell, index: Int) {
        // post picture, tap to like the post
        // index to get the post
        // create notification

        guard let userID = AuthManager.shared.userID else { return }
        
        if singlePost.post.likers.contains(userID) {

        } else {
            singlePost.post.likers.append(userID)
            singlePost.viewModel[3] = .actions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: singlePost.post.likers.contains(userID)))
        }

        DatabaseManager.shared.updateLikeState(
            state: .like,
            postID: singlePost.post.postID) { success in
                guard success else {
                    print("Failed to like from post picture")

                    return
                }
                print("Like post from post picture success!")

            }

        self.collectionView?.reloadData()
    }
}

extension PostViewController: PostActionsCollectionViewCellDelegate {

    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool, index: Int) {
        // 3 icons under picture, tap to like the post
        // call DB to update like state
        //        let tuple = allPosts[index]

        guard let userID = AuthManager.shared.userID
        else { return }
        if singlePost != nil {
            if singlePost.post.likers.contains(userID) {
                // remove userID from likers

                let likerIndex = singlePost.post.likers.firstIndex(of: userID)
                singlePost.post.likers.remove(at: likerIndex!)

                singlePost.viewModel[3] = .actions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: singlePost.post.likers.contains(userID)))

            } else {
                singlePost.post.likers.append(userID)
                singlePost.viewModel[3] = .actions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: singlePost.post.likers.contains(userID)))
            }
        }

        DatabaseManager.shared.updateLikeState(
            state: isLiked ? .like : .unlike,
            postID: singlePost.post.postID) { success in
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

        commentBarView.textfield.becomeFirstResponder()
    }

    func postActionsCollectionViewCellDidTapShare(_ cell: PostActionsCollectionViewCell) {

        let shareVC = UIActivityViewController(activityItems: ["Sharing from PurrfectPix"], applicationActivities: [])
        present(shareVC, animated: true)

    }
}

extension PostViewController: PostLikesCollectionViewCellDelegate {

    func postLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell, index: Int) {

        var count = singlePost.post.likers.count
        self.collectionView?.reloadData()

    }
}

extension PostViewController: PostCaptionCollectionViewCellDelegate {
    func postCaptionCollectionViewCellDidTapCaptioon(_ cell: PostCaptionCollectionViewCell, index: Int) {
        print("tapped caption")
    }
}

extension PostViewController: UICollectionViewDelegateFlowLayout {

    func configureCollectionView() {

        // calulate the heigh dynamically for square
        //        let sectionHeight: CGFloat = 410 + view.width
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

                let commentItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(60)
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
                        commentItem,
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
        // comment
        collectionView.register(CommentCollectionViewCell.self,
                                forCellWithReuseIdentifier: CommentCollectionViewCell.identifier)

        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)

        self.collectionView = collectionView  // configuring collectionView as it's own constance, and assign it to the global property
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//    }
}
