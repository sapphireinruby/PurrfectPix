//
//  ExploreViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/17/21.
//

import UIKit

class ExploreViewController: UIViewController, UISearchResultsUpdating {

    // Search controller
    private let searchVC = UISearchController(searchResultsController: SearchResultsViewController())

    // exploreo UI component
    private let collectionView: UICollectionView = {

        let layout = UICollectionViewCompositionalLayout { index, _ -> NSCollectionLayoutSection? in

            // item
            // First type: 1/3 view.width square
            let tripletSquareItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1/3),
                    heightDimension: .fractionalWidth(1/3)
                )
            )
            tripletSquareItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

            // First type: 1/3 view.width square for vertical stack group
            let tripletSquareItemVertical = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalWidth(1)  // 和外層group相對位置
                )
            )
            tripletSquareItemVertical.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

            // Second type: 3/2 view.width large square
            let largeSquareItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(2/3),
                    heightDimension: .fractionalWidth(2/3)
                )
            )
            largeSquareItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

            // group
            // 1. MAIN, 1/3 square x 3
            let threeItemGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(1/3)
                ),
                subitem: tripletSquareItem,
                count: 3
            )

            // 2. 1/3 square x 2 vertical
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1/3),
                    heightDimension: .fractionalWidth(2/3)
                ),
                subitem: tripletSquareItemVertical,
                count: 2
            )

            // 3. MAIN, one large at left, 2 small at right
            let horizontalComboOneGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(2/3)
                ),
                subitems: [
                    largeSquareItem,
                    verticalGroup
                ]
            )

            // 4. MAIN, 2 small at left, one large at right
            let horizontalComboTwoGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(2/3)
                ),
                subitems: [
                    verticalGroup,
                    largeSquareItem
                ]
            )

            let finalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(2.0)
                ),
                subitems: [
                    horizontalComboOneGroup,
                    threeItemGroup,
                    horizontalComboTwoGroup,
                    threeItemGroup
                ]
            )
            return NSCollectionLayoutSection(group: finalGroup)
        }

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PhotoCollectionViewCell.self,
                                forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        return collectionView
    }()

     var posts = [Post]()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Explore"
        view.backgroundColor = .systemBackground

        // search feature
        searchVC.searchBar.placeholder = "Search by username..."
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC

        (searchVC.searchResultsController as? SearchResultsViewController)?.delegate = self

        // explore view
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self

        // explore view data
        fetchData()

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
    
// search feature
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
              let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        DatabaseManager.shared.findUsers(username: query) { results in
            DispatchQueue.main.async {
                resultsVC.update(with: results)
            }
        }
    }

// explore view
private func fetchData() {
    DatabaseManager.shared.explorePosts { [weak self] posts in
//        DispatchQueue.main.async {
            self?.posts = posts
            self?.collectionView.reloadData()
//        }
    }
}
}

extension ExploreViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier,
            for: indexPath
        ) as? PhotoCollectionViewCell else {
            fatalError()
        }

        let model = posts[indexPath.row]
        cell.configure(with: URL(string: posts[indexPath.row].postUrlString))

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let post = posts[indexPath.row]
        let vcPostView = PostViewController(post: post)// 要接回去 或新開
        navigationController?.pushViewController(vcPostView, animated: true)
    }
}

extension ExploreViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewController(_ vc: SearchResultsViewController, didSelectResultWith user: User) {
        let profileVC = ProfileViewController(user: user)
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
