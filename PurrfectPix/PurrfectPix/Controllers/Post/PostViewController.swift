//
//  PostViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import UIKit

class PostViewController: UIViewController {

    private let post: Post

    // MARK: - Init

    init(
        post: Post
    ) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Post"
        view.backgroundColor = .systemBackground
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
