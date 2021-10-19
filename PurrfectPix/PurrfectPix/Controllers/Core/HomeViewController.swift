//
//  ViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/16/21.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // CollectionView for feed
    // calulate the heigh dynamically for square
    private var collectionView: UICollectionView?

    // Feed viewModels
    private var viewModels = [[HomeFeedCellType]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PurrfectPix"
        view.backgroundColor = .systemBackground
        configureCollectionView()
        fetchPosts()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }

    private func fetchPosts() {
        //for mock data
        let postData: [HomeFeedCellType] = [
            .poster(
                viewModel: PosterCollectionViewCellViewModel(
                    username: "Elio_puppylover",
                    profilePictureURL: URL(string: "https://scontent.ftpe8-1.fna.fbcdn.net/v/t1.6435-9/242945276_3054696211465194_1423317400057496127_n.jpg?_nc_cat=105&ccb=1-5&_nc_sid=730e14&_nc_eui2=AeEbjFUHsYJ9EqZsgBq5zb-iT_Ih7fxGqB5P8iHt_EaoHlf59JU9QFYyrEPXsPaxOh8&_nc_ohc=scAT0OX2pHYAX8-fa9T&_nc_ht=scontent.ftpe8-1.fna&oh=6a400e2c4fa886fa84048e8a921feb8f&oe=6193614C")!
                )
            ),

            .post(
                viewModel: PostCollectionViewCellViewModel(
                    postUrl: URL(string: "https://scontent.ftpe8-4.fna.fbcdn.net/v/t1.6435-9/242633552_3054696328131849_3707480464591953262_n.jpg?_nc_cat=104&ccb=1-5&_nc_sid=730e14&_nc_eui2=AeFwzWTKCl1GNGMIiuY4k5x9GSSG4ACEIPgZJIbgAIQg-NV4mUAjCylLcLzVRJZY_LQ&_nc_ohc=Hb6Ttf8GCf4AX-sfWIS&_nc_ht=scontent.ftpe8-4.fna&oh=649ca474cd9dcea8f97ed3b53e459ad9&oe=61952033")!
                )
            ),

            .petTag(viewModel: PostPetTagCollectionViewCellViewModel(
                petTag: "Dog"
                )
            ),

            .actions(viewModel: PostActionsCollectionViewCellViewModel(
                    isLiked: true
                )
            ),

            .likeCount(viewModel: PostLikesCollectionViewCellViewModel(likers: ["Amber_cat", "Zeo666", "Alliee"])),

            .caption(viewModel: PostCaptionCollectionViewCellViewModel(username: "Amber_cat", caption: "太可愛了吧～～～！")),

            .timestamp(viewModel: PostDatetimeCollectionViewCellViewModel(date: Date()))

        ]

        viewModels.append(postData)
        collectionView?.reloadData()

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
        let celltype = viewModels[indexPath.section][indexPath.row]
        switch celltype {

        case .poster(let viewModel):
            break
        case .post(let viewModel):
            break
        case .petTag(let viewModel):
            break
        case .actions(let viewModel):
            break
        case .likeCount(let viewModel):
            break
        case .caption(let viewModel):
            break
        case .timestamp(let viewModel):
            break
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = colors[indexPath.row]

        return cell
    }
}

extension HomeViewController {

    func configureCollectionView() {

        let sectionHeight = CGFloat( 60 + 40 + (view.frame.size.width))
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
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell"
        )
        self.collectionView = collectionView
    }

}
