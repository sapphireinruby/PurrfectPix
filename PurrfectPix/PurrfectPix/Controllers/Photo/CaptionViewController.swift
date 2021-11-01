//
//  CaptionViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import UIKit
import TTGTags

class CaptionViewController: UIViewController, UITextViewDelegate, TTGTextTagCollectionViewDelegate {

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

//  Pet hashtag
    private let tagView = TTGTextTagCollectionView()


// MARK: - Init section

    init(image: UIImage) {

        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // for pet tag
    private var petTags = [String]()

    let tagString = [
        "#汪星人", "#貓星人", "#鳥類", "#兔兔", "#齧齒動物",
        "爬蟲類", "#刺蝟", "#小豬", "#其他寶貝",
        "#療癒", "#可愛", "#激萌", "#搞笑", "#臭臉王",
        "#看一天都不累", "#被主子認可了", "#我不想睡",
        "#在忙什麼啦", "#meme迷因有梗圖",
        "#小短腿", "#小胖胖", "#圓臉臉",
        "#抱緊處理", "#玩我最在行", "#該放飯了吧", "#別人的寵物都不會讓我失望",
        "#領養最棒", "#浪浪需要你"
    ]

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

        // pet tag collectionview
        view.addSubview(tagView)
        tagView.alignment = .center
        tagView.delegate = self

        // Add tag

        for text in tagString {

            let content = TTGTextTagStringContent.init(text: text)
//            content.textFont = UIFont.boldSystemFont(ofSize: 12)
            content.textColor = .label

            // nomore tag
            let normalStyle = TTGTextTagStyle.init()
            normalStyle.backgroundColor = .secondarySystemBackground
            normalStyle.extraSpace = CGSize.init(width: 12, height: 12)
            normalStyle.borderColor = UIColor.purple
            normalStyle.borderWidth = 1

            // selected tag
            let selectedStyle = TTGTextTagStyle.init()
            selectedStyle.backgroundColor = .secondarySystemBackground
            selectedStyle.borderColor = UIColor.purple
            selectedStyle.borderWidth = 3
            selectedStyle.extraSpace = CGSize.init(width: 12, height: 12)

            let tag = TTGTextTag.init()
            tag.content = content
            tag.style = normalStyle
            tag.selectedStyle = selectedStyle

            tagView.addTag(tag)
        }

        tagView.reload()
    }

    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTap tag: TTGTextTag!, at index: UInt) {

        let text = tag.content.getAttributedString().string

        if petTags.contains(text) {

        let index = petTags.firstIndex(of: text)
            petTags.remove(at: index!)
            
        } else {
            petTags.append(text)
        }
        print("petTags are \(petTags)")
    }

    @objc func didTapPost() {

        textView.resignFirstResponder()

        // clean the text view placeholder
        var caption = textView.text ?? ""
        if caption == "Add caption" {

            caption = ""
        }

        var petTags = petTags

        // show.progress() 安裝 stylish裡的 轉轉轉的 pods

        // Generate post ID --> Image & the whole Post share one ID
        guard let newPostID = createNewPostID(),
              let stringDate = String.date(from: Date()) else {
            return
        }

        // Upload Post --> Image & the whole Post share one ID
        guard let userID = UserDefaults.standard.string(forKey: "userID") else { return }
        StorageManager.shared.uploadPost(

            data: image.pngData(),
            userID: userID,
            postID: newPostID
            
        ) { newPostDownloadURL in
            guard let url = newPostDownloadURL?.absoluteString else {
                print("error: failed to upload to storage")
                return
            }

            // New Post
            // storage ref: username/posts/png
            // swiftlint:disable:next line_length
            let newPost = Post(
                userID: userID,
                postID: newPostID,
                caption: caption,
                petTag: petTags,
                postedDate: stringDate,
                likers: [String](),
                comments: [CommentByUser](),
                postUrlString: url,
                location: ""
            )

            // Update Database
            DatabaseManager.shared.createPost(newPost: newPost) { [weak self] finished in
                guard finished else {
                    // show.progress(falls "送出失敗")
                    return
                }

                // show.progress(success "成功送出了！")

                DispatchQueue.main.async {

                    //  weak self avoid memory leak
                    self?.tabBarController?.tabBar.isHidden = false
                    self?.tabBarController?.selectedIndex = 0 // back to home
                    self?.navigationController?.popToRootViewController(animated: false)
                }
            }
        }

    }

    // for storage 的post --> Image
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
        let size: CGFloat = view.width / 3

        imageVIew.frame = CGRect(
            x: (view.width-size) / 2,
            y: view.safeAreaInsets.top + 80,
            width: size,
            height: size
        )

        textView.frame = CGRect(
            x: 24,
            y: imageVIew.bottom + 16,
            width: view.width - 48,
            height: 160
        )

        tagView.frame = CGRect(
            x: 24,
            y: textView.bottom + 16,
            width: view.width - 48,
            height: 600
        )
    }

    func textViewDidBeginEditing(_ textView: UITextView) {

        // pops up the keyboard
        if textView.text == "Add caption" {
            textView.text = nil
        }
    }

}


