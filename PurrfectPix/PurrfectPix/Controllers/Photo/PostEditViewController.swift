//
//  PostEditViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/22/21.
//

import CoreImage
import UIKit

class PostEditViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private var filters = [UIImage]()
    var filterStyles: [FilterType] = [.autoAdjust, .vibrance, .ciSepiaTone, .ciGaussianBlur, .ciHighlightShadowAdjust, .ciColorMonochrome ]

    private let imageView: UIImageView = {

        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView

    }()

    // add a collection view for filters
    private let collectionView: UICollectionView = {

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 48
        layout.minimumInteritemSpacing = 24
        layout.itemSize.width = 48
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
            x: -2,
            y: view.safeAreaInsets.top,
            width: view.width + 4,
            height: view.width
        )
        collectionView.frame = CGRect(
            x: 16,
            y: imageView.bottom + 24,
            width: view.width - 32,
            height: view.height
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


    enum FilterType: String {

        case autoAdjust = "Auto Adjustment"
        case vibrance = "Vibrance"
        case ciSepiaTone = "Sepia Tone"
        case ciHighlightShadowAdjust = "Highlight Shadow"
        case ciGaussianBlur = "Gaussian Blur"
        case ciColorMonochrome = "Monochrome"
    }

    private func filterImage (image: UIImage, filterStyle: FilterType) {
        // UIImage -> core image/CIImage: CI Filter -> core graphic -> UIImage
        // UIImage ??????????????????????????????????????? CIImage
        // UIImage ????????? CIImage ??????, ???UIImage????????? nil???
        // ???????????? UIImage ?????? CGImage????????? CGImage ?????? CIImage??????????????? Core Image APIs ?????????
        // ??????????????????????????????????????? CIImage ????????? UIImage????????? UIImageView ???????????????

        guard let cgImage = image.cgImage else { return } //  image: UIImage

        var filter: CIFilter?

        var autoOutputCIImage: CIImage?

        var outputCIImage: CIImage?

        switch filterStyle {

        case .autoAdjust:

            let inputImage = CIImage(cgImage: cgImage)
            let filters = inputImage.autoAdjustmentFilters()
            for filter: CIFilter in filters {
                filter.setValue(inputImage, forKey: kCIInputImageKey)
                autoOutputCIImage = filter.outputImage!
            }

        case .vibrance:

            filter = CIFilter(name: "CIVibrance")
            filter?.setValue(CIImage(cgImage: cgImage), forKey: "inputImage")
            filter?.setValue(1, forKey: "inputAmount")
            outputCIImage = filter?.outputImage

        case .ciSepiaTone:

            filter = CIFilter(name: "CISepiaTone")
            filter?.setValue(CIImage(cgImage: cgImage), forKey: "inputImage")
            filter?.setValue(0.7, forKey: "inputIntensity")
            outputCIImage = filter?.outputImage

        case .ciHighlightShadowAdjust:
            filter = CIFilter(name: "CIHighlightShadowAdjust")
            filter?.setValue(CIImage(cgImage: cgImage), forKey: "inputImage")
            filter?.setValue(0.75, forKey: "inputHighlightAmount")
            filter?.setValue(0.3, forKey: "inputShadowAmount")
            outputCIImage = filter?.outputImage

        case .ciGaussianBlur:
            filter = CIFilter(name: "CIGaussianBlur")
            filter?.setValue(CIImage(cgImage: cgImage), forKey: "inputImage")
            filter?.setValue(0.8, forKey: "inputRadius")
            outputCIImage = filter?.outputImage

        case .ciColorMonochrome:
            filter = CIFilter(name: "CIColorMonochrome")
            filter?.setValue(CIImage(cgImage: cgImage), forKey: "inputImage")
            filter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
            filter?.setValue(1.0, forKey: "inputIntensity")
            outputCIImage = filter?.outputImage

        default:
            filter = CIFilter(name: "CIHighlightShadowAdjust")
            filter?.setValue(CIImage(cgImage: cgImage), forKey: "inputImage")
            filter?.setValue(1.0, forKey: "inputHighlightAmount")
            outputCIImage = filter?.outputImage

        }

        if autoOutputCIImage != nil {

            guard let autoImage = autoOutputCIImage else {
                return
            }
            let context = CIContext()

            if let autoImage = context.createCGImage(
                autoImage,
                from: autoImage.extent
            ) {
                let filteredImage = UIImage(cgImage: autoImage)

                imageView.image = filteredImage
            }
            self.imageView.image = UIImage(ciImage: autoImage)

        } else if outputCIImage != nil {

            guard let outputImage = filter?.outputImage else {
                return

            }

            let context = CIContext()

            if let outputcgImage = context.createCGImage(
                outputImage,
                from: outputImage.extent
            ) {
                let filteredImage = UIImage(cgImage: outputcgImage)

                imageView.image = filteredImage
            }

        } else {
            print("image filtering failed")
        }

    }

    // CollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterStyles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionViewCell.identifier,
            for: indexPath
        ) as? PhotoCollectionViewCell else {
            fatalError()
        }

        cell.configure(style: filterStyles[indexPath.row].rawValue)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        collectionView.deselectItem(at: indexPath, animated: true)
        filterImage(image: image, filterStyle: filterStyles[indexPath.row])
    }
}
