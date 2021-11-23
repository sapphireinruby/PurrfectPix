//
//  SignUpViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import UIKit
import FirebaseAuth
import SafariServices

class SignUpViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Subviews

    private let profilePictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .lightGray
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .P1
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 45
        return imageView
    }()

    private let usernameField: UserTextField = {
        let field = UserTextField()
        field.placeholder = "Username"
        field.returnKeyType = .next
        field.autocorrectionType = .no
        return field
    }()

    private let emailField: UserTextField = {
        let field = UserTextField()
        field.placeholder = "Email Address"
        field.keyboardType = .emailAddress
        field.returnKeyType = .next
        field.autocorrectionType = .no
        return field
    }()

    private let passwordField: UserTextField = {
        let field = UserTextField()
        field.placeholder = "Create Password"
        field.isSecureTextEntry = true
        field.keyboardType = .default
        field.returnKeyType = .continue
        field.autocorrectionType = .no
        return field
    }()

    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = .P1
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()

//    private let agreetmentLabel: UILabel = {
//        let label = UILabel()
//        label.text = "By click Sing Up, you agreeto to our Terms."
//        label.textColor = .P1
//        label.textAlignment = .center
//        label.isHidden = true
//        return label
//    }()

    private let agreetmentButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.P1, for: .normal)
        button.setTitle("By Click Sing Up, \nYou Agree to Our Terms Below.", for: .normal)
        button.titleLabel?.lineBreakMode = .byWordWrapping // multi-line text in UIButton
        button.titleLabel?.textAlignment = .center
        return button
    }()

    private let termsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        button.setTitle("End User License Agreement", for: .normal)
        return button
    }()

    private let privacyButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        button.setTitle("Privacy Policy", for: .normal)
        return button
    }()

    public var completion: (() -> Void)?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        view.backgroundColor = .systemBackground
        addSubviews()
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        addButtonActions()
        addImageGesture()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageSize: CGFloat = 90

        profilePictureImageView.frame = CGRect(
            x: (view.width - imageSize)/2,
            y: view.safeAreaInsets.top + 15,
            width: imageSize,
            height: imageSize
        )

        usernameField.frame = CGRect(x: 35, y: profilePictureImageView.bottom+16, width: view.width-70, height: 50)
        emailField.frame = CGRect(x: 35, y: usernameField.bottom+8, width: view.width-70, height: 50)
        passwordField.frame = CGRect(x: 35, y: emailField.bottom+8, width: view.width-70, height: 50)
        signUpButton.frame = CGRect(x: 35, y: passwordField.bottom+16, width: view.width-70, height: 50)

//        agreetmentLabel.frame = CGRect(x: 35, y: signUpButton.bottom + 24, width: view.width-70, height: 40)
        agreetmentButton.frame = CGRect(x: 35, y: signUpButton.bottom + 24, width: view.width-70, height: 40)

        termsButton.frame = CGRect(x: 35, y: agreetmentButton.bottom + 16, width: view.width-70, height: 40)
        privacyButton.frame = CGRect(x: 35, y: termsButton.bottom + 8, width: view.width-70, height: 40)
    }

    private func addSubviews() {
        view.addSubview(profilePictureImageView)
        view.addSubview(usernameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
//        view.addSubview(agreetmentLabel)
        view.addSubview(agreetmentButton)
        view.addSubview(termsButton)
        view.addSubview(privacyButton)
    }

    private func addImageGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        profilePictureImageView.isUserInteractionEnabled = true
        profilePictureImageView.addGestureRecognizer(tap)
    }

    private func addButtonActions() {
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(didTapTerms), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(didTapPrivacy), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc func didTapImage() {
        let sheet = UIAlertController(
            title: "Profile Picture",
            message: "Set a picture to help your friends find you :)",
            preferredStyle: .actionSheet
        )

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in

            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.allowsEditing = true
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        sheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.allowsEditing = true
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        present(sheet, animated: true)
    }

    @objc func didTapSignUp() {

        usernameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
//        // lottie for loding
//        let animationView = self.setupAnimation(name: "890-loading-animation", mood: .autoReverse)
//        animationView.play()

        guard let username = usernameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              !username.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6,
              username.count >= 2,
              username.trimmingCharacters(in: .alphanumerics).isEmpty else {
            presentError()
            return
        }

        let data = profilePictureImageView.image?.pngData()

        // Sign up with authManager

        AuthManager.shared.signUp(
            userID: "",
            email: email,
            username: username,
            password: password,
            profilePicture: data
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):  // user model

//                    let newSignUpUser = User(userID: "", username: username, email: email, profilePic: profilePicture, followingUsers: [String](), logInCount: 0)
//                    DatabaseManager.shared.createUser(newUser: newSignUpUser) { isSuccess in
//                        if isSuccess {
//                            print("New sign up user username in database is now \(newSignUpUser.username)")
//
//                        } else {
//                            print("save username to firebase error")
//                        }
//                    }


                    HapticManager.shared.vibrate(for: .success)

                    // if sign in success, present home screen
                    let vcTabBar = TabBarViewController()
                    vcTabBar.modalPresentationStyle = .fullScreen
                    self?.present(
                        vcTabBar,
                        animated: true,
                        completion: nil
                    )
//                    self?.completion?()
                case .failure(let error):
                    HapticManager.shared.vibrate(for: .error)
                    print("\n\nSign Up Error: \(error)")
                }
            }
        }
    }

    private func presentError() {
        let alert = UIAlertController(title: "Woops",
                                      message: "Please make sure to fill all fields and have a password longer than 6 characters.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    @objc func didTapTerms() {
        guard let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") else {
            return
        }
        let vcSF = SFSafariViewController(url: url)
        present(vcSF, animated: true)
    }

    @objc func didTapPrivacy() {
        guard let url = URL(string: "https://www.privacypolicies.com/live/dd1fde8e-ef94-48a1-8b08-49b95c29ac5e") else {
            return
        }
        let vcWeb = SFSafariViewController(url: url)
        present(vcWeb, animated: true)
    }

    // MARK: Field Delegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == usernameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            didTapSignUp()
        }
        return true
    }

    // Image Picker

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        profilePictureImageView.image = image
    }

}
