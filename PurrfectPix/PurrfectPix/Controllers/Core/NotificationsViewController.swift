//
//  NotificationsViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/17/21.
//

import UIKit
import Lottie

class NotificationsViewController: UIViewController {

//    @IBOutlet weak var animationView: AnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()

        
//
//        title = "Notifications "
//        view.backgroundColor = .systemBackground

//        animationView.loopMode = .autoReverse
//        animationView.animationSpeed = 0.5

        let animationView = AnimationView(name: "68349-cat-tail-wag")
        animationView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .autoReverse
        animationView.animationSpeed = 0.5
        animationView.backgroundBehavior = .pauseAndRestore // restart from other tab bar item

        view.addSubview(animationView)

        animationView.play()

}

}
