//
//  PostEditViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/22/21.
//

import CoreImage
import UIKit

class PostEditViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private var filters = [UIImage]() // array for filter images

    private let imageView: UIImageView = {

        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView

    }()

    // add a collection view for filters
    private let collectionView: UICollectionView = {

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.backgroundColor = .secondarySystemBackground

        // under Views
        collectionView.register(PhotoCollectionViewCell.self,
                                forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        return collectionView
    }()

    private let image: UIImage

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        title = "Edit Photo"

        imageView.image = image
        view.addSubview(imageView)

        setUpFilters()

        // filters collectionView
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(didTapNext))
    }

    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.width,
            height: view.width
        )
        collectionView.frame = CGRect(
            x: 0,
            y: imageView.bottom+20,
            width: view.width,
            height: 100
        )
    }

    @objc func didTapNext() {
        guard let current = imageView.image else { return }
        // image -> before filter; current -> after filter
        
        let afterFilterVC = CaptionViewController(image: current)
        
        afterFilterVC.title = "Add caption"
        navigationController?.pushViewController(afterFilterVC, animated: true)
    }

    private func setUpFilters() {
        guard let filterImage = UIImage(systemName: "camera.filters") else {
            return
        }
        filters.append(filterImage)
    }

        private func filterImage(image: UIImage) {
        // core image -> core graphic -> UIImage

            guard let cgImage = image.cgImage else { return }

            let filter = CIFilter(name: "CIHighlightShadowAdjust")

            filter?.setValue(CIImage(cgImage: cgImage), forKey: "inputImage")
            filter?.setValue(0.5, forKey: "inputHighlightAmount")

            guard let outputImage = filter?.outputImage else { return }

            let context = CIContext()

            if let outputcgImage = context.createCGImage(
                outputImage,
                from: outputImage.extent
            ) {
                let filteredImage = UIImage(cgImage: outputcgImage)

                imageView.image = filteredImage
            }
        }

//    private func filterImage(image: UIImage) {
//    // core image -> core graphic -> UIImage
//
//        guard let cgImage = image.cgImage else { return }
//
//        // CISepiaTone filter
//        let filter = CIFilter(name: "CISepiaTone")
//
//        switch filter {
//        case CIFilter(name: "CISepiaTone"):
//            filter?.setValue(1.0, forKey: "inputIntensity")
//
//        case CIFilter(name: "CIHighlightShadowAdjust"):
//            filter?.setValue(1.0, forKey: "inputHighlightAmount")
//
//        case CIFilter(name: "CIGaussianBlur"):
//            filter?.setValue(2.0, forKey: "inputRadius")
//
//        case CIFilter(name: "CIColorMonochrome"):
//            filter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
//            filter?.setValue(1.0, forKey: "inputIntensity")
//        default:
//            filter?.setValue(1.0, forKey: "inputHighlightAmount")
//        }
//
//        guard let outputImage = filter?.outputImage else { return }
//
//        let context = CIContext()
//
//        if let outputcgImage = context.createCGImage(
//            outputImage,
//            from: outputImage.extent
//        ) {
//            let filteredImage = UIImage(cgImage: outputcgImage)
//
//            imageView.image = filteredImage
//        }
//    }

//    private func filterImage(image: UIImage) {
//    // core image -> core graphic -> UIImage
//
//        guard let cgImage = image.cgImage else { return }
//
//        // black and white filter
//        let filter = CIFilter(name: "CIColorMonochrome")
//
//        filter?.setValue(CIImage(cgImage: cgImage), forKey: "inputImage")
//        filter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
//        filter?.setValue(1.0, forKey: "inputIntensity")
//
//        guard let outputImage = filter?.outputImage else { return }
//
//        let context = CIContext()
//
//        if let outputcgImage = context.createCGImage(
//            outputImage,
//            from: outputImage.extent
//        ) {
//            let filteredImage = UIImage(cgImage: outputcgImage)
//
//            imageView.image = filteredImage
//        }
//    }

    // CollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionViewCell.identifier,
            for: indexPath
        ) as? PhotoCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: filters[indexPath.row], style: "")

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        collectionView.deselectItem(at: indexPath, animated: true)
        filterImage(image: image)
    }
}
