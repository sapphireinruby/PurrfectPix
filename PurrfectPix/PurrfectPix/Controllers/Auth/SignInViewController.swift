//
//  SingInViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import SafariServices
import UIKit
import AuthenticationServices

class SignInViewController: UIViewController, UITextFieldDelegate {

    // Subviews

    private let headerView = SignInHeaderView()

    private let signInWithAppleButton = ASAuthorizationAppleIDButton()

//    private let signInWithAppleButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("Sign In with Apple", for: .normal)
//        button.backgroundColor = .systemBlue
//        button.layer.cornerRadius = 8
//        button.layer.masksToBounds = true
//        return button
//    }()

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
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        field.keyboardType = .default
        field.returnKeyType = .continue
        field.autocorrectionType = .no
        return field
    }()

    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = .P1
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()

    private let createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.P1, for: .normal)
        button.setTitle("Create Accoount", for: .normal)
        return button
    }()

    private let termsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        button.setTitle("Terms of Service", for: .normal)
        return button
    }()

    private let privacyButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        button.setTitle("Privacy Policy", for: .normal)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        view.backgroundColor = .systemBackground
        addSubviews()

        // turn off the keyboard
        emailField.delegate = self
        passwordField.delegate = self

        addButtonActions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.width,
            height: (view.height - view.safeAreaInsets.top)/3
        )

        signInWithAppleButton.frame = CGRect(x: 40, y: headerView.bottom + 48, width: view.width - 80, height: 50)
        emailField.frame = CGRect(x: 24, y: signInWithAppleButton.bottom + 20, width: view.width - 48, height: 50)
        passwordField.frame = CGRect(x: 24, y: emailField.bottom + 10, width: view.width - 50, height: 48)
        
        signInButton.frame = CGRect(x: 40, y: passwordField.bottom + 20, width: view.width - 80, height: 50)
        createAccountButton.frame = CGRect(x: 40, y: signInButton.bottom + 20, width: view.width - 80, height: 50)
        termsButton.frame = CGRect(x: 40, y: createAccountButton.bottom + 50, width: view.width - 80, height: 40)
        privacyButton.frame = CGRect(x: 40, y: termsButton.bottom + 10, width: view.width - 80, height: 40)
    }

    private func addSubviews() {

        view.addSubview(headerView)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signInButton)
        view.addSubview(createAccountButton)
        view.addSubview(signInWithAppleButton)

//        view.addSubview(termsButton)
//        view.addSubview(privacyButton)
    }

    private func addButtonActions() {

        signInWithAppleButton.addTarget(self, action: #selector(didTapSinginWithApple), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccount), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(didTapTerms), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(didTapPrivacy), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc func didTapSinginWithApple() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()

    }


    @objc func didTapSignIn() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()

        guard let email = emailField.text,
              let password = passwordField.text,
              // use white space to see if it's empty
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6 else {
            return
        }

//         Sign in with authManager
        
        AuthManager.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
//                    HapticManager.shared.vibrate(for: .success)
                    let vc = TabBarViewController()
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(
                        vc,
                        animated: true,
                        completion: nil
                    )

                case .failure(let error):
//                    HapticManager.shared.vibrate(for: .error)
                    print(error)
                }
            }
        }
    }

    @objc func didTapCreateAccount() {
        let vc = SignUpViewController()
        vc.completion = { [weak self] in
            DispatchQueue.main.async {
                let tabVC = TabBarViewController()
                tabVC.modalPresentationStyle = .fullScreen
                self?.present(tabVC, animated: true)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func didTapTerms() {
        guard let url = URL(string: "https://") else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }

    @objc func didTapPrivacy() {
        guard let url = URL(string: "https://") else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }

    // MARK: Field Delegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            didTapSignIn()
        }
        return true
    }
}

extension SignInViewController: ASAuthorizationControllerDelegate {

}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }


}
