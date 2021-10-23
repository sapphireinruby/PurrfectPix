//
//  CaptionViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import UIKit

class CaptionViewController: UIViewController, UITextViewDelegate {

    // show the pictre user just took
    private let image: UIImage

    private let imageVIew: UIImageView = {

        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let textView: UITextView = {

        let textView = UITextView()
        textView.text = "Add caption"
        textView.backgroundColor = .secondarySystemBackground
        textView.font = .systemFont(ofSize: 20)

        textView.textContainerInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return textView
    }()

//  Pet hashtag will do it later
//    private let tagView: UIcollectionView = {
//
//        let textView = UITextView()
//        textView.text = "Add caption / 添加文字"
//        textView.backgroundColor = .secondarySystemBackground
//        textView.font = .systemFont(ofSize: 18)
//
//        textView.textContainerInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
//        return textView
//    }()

// MARK: - Init section

    init(image: UIImage) {

        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(imageVIew)
        imageVIew.image = image
        view.addSubview(textView)

        textView.delegate = self

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Post",
            style: .done,
            target: self,
            action: #selector(didTapPost))
    }

    @objc func didTapPost() {

        textView.resignFirstResponder() // turn off keyboard

        var caption = textView.text ?? ""
        if caption == "Add caption/寫點東西" {
            caption = ""

        }

        // Generate post ID --> Image & the whole Post share one ID
        guard let newPostID = createNewPostID(),
              let stringDate = String.date(from: Date()) else {
            return
        }

        // Upload Post --> Image & the whole Post share one ID
        StorageManager.shared.uploadPost(
            data: image.pngData(),
            id: newPostID
        ) { newPostDownloadURL in
            guard let url = newPostDownloadURL else {
                print("error: failed to upload to storage")
                return
            }

            // New Post
            // storage ref: username/posts/png

            let newPost = Post(userID:"", postID: newPostID, caption: caption, petTag: "", postedDate: stringDate, likers: [String](), comments: [CommentByUser](), postUrlString: "", location: ""
            )

            // Update Database
            DatabaseManager.shared.createPost(newPost: newPost) { [weak self] finished in
                guard finished else {
                    return
                }
                DispatchQueue.main.async {

                    //  weak self avoid memory leak
                    self?.tabBarController?.tabBar.isHidden = false
                    self?.tabBarController?.selectedIndex = 0
                    self?.navigationController?.popToRootViewController(animated: false)
                }
            }
        }

    }

    // for storage 的post --> ImagePost
    private func createNewPostID() -> String? {

        let timeStamp = Date().timeIntervalSince1970
        let randomNumber = Int.random(in: 0...1000)

        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            return nil
        }

        return "\(userID)_\(randomNumber)_\(timeStamp)"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size: CGFloat = view.width / 4

        imageVIew.frame = CGRect(
            x: (view.width-size) / 2,
            y: view.safeAreaInsets.top + 160,
            width: size,
            height: size
        )

        textView.frame = CGRect(
            x: 16,
            y: imageVIew.bottom + 16,
            width: view.width - 40,
            height: 160
        )
    }

    func textViewDidBeginEditing(_ textView: UITextView) {

        // pops up the keyboard
        if textView.text == "Add caption/寫點東西" {
            textView.text = nil
        }
    }

}
