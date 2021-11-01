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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Explore"
        view.backgroundColor = .systemBackground
        searchVC.searchBar.placeholder = "Search..."
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC

        (searchVC.searchResultsController as? SearchResultsViewController)?.delegate = self
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
              let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        DatabaseManager.shared.findUsers(with: query) { results in
            DispatchQueue.main.async {
                resultsVC.update(with: results)
            }
        }
    }
}

extension ExploreViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewController(_ vc: SearchResultsViewController, didSelectResultWith user: User) {
        let profileVC = ProfileViewController(user: user)
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
