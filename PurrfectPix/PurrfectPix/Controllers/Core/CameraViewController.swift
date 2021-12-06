//
//  CameraViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/17/21.
//

import UIKit
import AVFoundation

// Controller to handle taking pictures or choosing from Library
final class CameraViewController: UIViewController {

    private var output = AVCapturePhotoOutput()
    private var captureSession: AVCaptureSession?
    private let previewLayer = AVCaptureVideoPreviewLayer() // get global safe area

        private let remindingLabel: UILabel = {
            let label = UILabel()
            label.text = "Please upload Image with Animal only.\nPost without Animal might be \nReported and Deleted. \nU•ェ•U Thank you!"
            label.textColor = .P1
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.textAlignment = .center
            return label
        }()

    private let cameraView = UIView()
    // for adding a preview layer after taking photo

    private let shutterButton: UIButton = {

        let button = UIButton()
        button.tintColor = .P1
        button.setImage(UIImage(systemName: "camera.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 60)),
                        for: .normal)

        return button

    }()

    private let photoPickerButton: UIButton = {

        let button = UIButton()
        button.tintColor = .P2
        button.setImage(UIImage(systemName: "photo.on.rectangle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 60)),
                        for: .normal)
        return button

    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        title = "Take Photo"

        view.addSubview(remindingLabel)
        view.addSubview(cameraView)
        view.addSubview(shutterButton)
        view.addSubview(photoPickerButton)

        setUpNavBar()
        checkCameraPermission()

        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        
        photoPickerButton.addTarget(self, action: #selector(didTapPickPhoto), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        // turn camera back on when back in this mode
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = true
        if let session = captureSession, !session.isRunning {
            session.startRunning()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        // turn camera off on when out off this mode
        super.viewDidDisappear(animated)
        captureSession?.stopRunning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        cameraView.frame = view.bounds
        // make the frame squire
        previewLayer.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top + 24,
            width: view.width,
            height: view.width
        )

        let buttonSize: CGFloat = view.width/5

        shutterButton.frame = CGRect(
            x: (view.width-buttonSize)/2,
            y: view.safeAreaInsets.top + view.width + 40,
            width: buttonSize,
            height: buttonSize
        )

        photoPickerButton.frame = CGRect(
            x: (view.width-buttonSize)/2,
            y: shutterButton.bottom + 16,
            width: buttonSize,
            height: buttonSize
        )

        remindingLabel.frame = CGRect(
            x: 32,
            y: photoPickerButton.bottom + 8,
            width: view.width - 64,
            height: view.width
        )

    }

    @objc func didTapPickPhoto() {

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)

    }

    @objc func didTapTakePhoto() {
        output.capturePhoto(with: AVCapturePhotoSettings(),
                            delegate: self)
    }

    private func checkCameraPermission() {

        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .notDetermined:
            // request
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
            }
        case .authorized:
            setUpCamera()
        case .restricted, .denied:
            break
        @unknown default:
            break
        }

    }

    private func setUpCamera() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch {
                print(error)
            }

            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }

            // for adding a preview layer after taking photo
            cameraView.layer.addSublayer(previewLayer)
            previewLayer.session = captureSession
            previewLayer.videoGravity = .resizeAspectFill

            captureSession.startRunning()
        }
    }

    @objc func didTapClose() {

        tabBarController?.selectedIndex = 0
        tabBarController?.tabBar.isHidden = false
    }

    private func setUpNavBar() {
        // take the tabbar off and exit the camera mode
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        showEditPhoto(image: image)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            return
        }
        captureSession?.stopRunning()
        showEditPhoto(image: image)
    }

    private func showEditPhoto(image: UIImage) {

        // to fix the image rotation issue
        guard let resizedImage = image.sd_resizedImage(
            
            with: CGSize(width: 640, height: 640),
            scaleMode: .aspectFill
        ) else {
            
            return
        }

        let vcPost = PostEditViewController(image: resizedImage)
        // vc under photo folder
        
        if #available(iOS 14.0, *) {
            vcPost.navigationItem.backButtonDisplayMode = .minimal
        }
        navigationController?.pushViewController(vcPost, animated: false)

    }
}
