//
//  ViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/16/21.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource {

    // CollectionView for feed
    private let collectionView: UICollectionView = UICollectionView(
        frame: . zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(
            sectionProvider: {  index, _ -> NSCollectionLayoutSection? in

                //item
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1), // 100%
                        heightDimension: .fractionalHeight(1) // 100%
                    )
                )


                //group
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1), // 100%
                        heightDimension: .absolute(100)
                    ),
                    subitem: item, count: 1)



                //section
                return NSCollectionLayoutSection(group: group)
            })
    )



    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PurrfectPix"
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        configureCollectionView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }

    // collectionView

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = .red

        return cell
    }
}
