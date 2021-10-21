//
//  CameraViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/17/21.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = .black
//        view.backgroundColor = .secondarySystemBackground

        // for the exit button
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))


        title = "Take Photo or Choose a Picture"
        view.addSubview(photoPickerButton)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated) // to get ride off the tab bar, need an exit on top left
        tabBarController?.tabBar.isHidden = true

    }

    @objc func didTapClose() {
        
    }


    private let photoPickerButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(UIImage(systemName: "photo", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40)),
                        for: .normal)
        return button
    }()


}
