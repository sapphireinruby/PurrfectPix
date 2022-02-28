//
//  SingInViewController.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import SafariServices
import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth

class SignInViewController: UIViewController, UITextFieldDelegate {

    // Subviews

    private let headerView = SignInHeaderView()

    private let signInWithAppleButton = ASAuthorizationAppleIDButton()

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
        button.setTitle("End User License Agreement", for: .normal)
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

        termsButton.frame = CGRect(x: 40, y: createAccountButton.bottom + 10, width: view.width - 80, height: 40)

        privacyButton.frame = CGRect(x: 40, y: termsButton.bottom + 10, width: view.width - 80, height: 40)
    }

    private func addSubviews() {

        view.addSubview(headerView)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signInButton)
        view.addSubview(createAccountButton)
        view.addSubview(signInWithAppleButton)

        view.addSubview(termsButton)
        view.addSubview(privacyButton)
    }

    private func addButtonActions() {

        signInWithAppleButton.addTarget(self, action: #selector(didTapSinginWithApple), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccount), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(didTapTerms), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(didTapPrivacy), for: .touchUpInside)
    }

    // MARK: - Actions

    // MARK: - Sign in with Apple
    @objc func didTapSinginWithApple() {

        performSignIn()
    }

    func performSignIn() {

        let animationView = self.createAnimation(name: "890-loading-animation", mood: .autoReverse)
        animationView.play()

        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {

                let appleIDProvider = ASAuthorizationAppleIDProvider()
                let request = appleIDProvider.createRequest()
                request.requestedScopes = [.fullName, .email]

                let nonce = randomNonceString()
                request.nonce = sha256(nonce)
                currentNonce = nonce
                return request
    }

    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }

    // Unhashed nonce.
    fileprivate var currentNonce: String?

    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce

      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
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
        
        AuthManager.shared.signIn(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    HapticManager.self

                    // if sign in success, present home screen
                    guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
                    let vcTabBar = TabBarViewController()
                    window.rootViewController = vcTabBar

                case .failure(let error):
                    HapticManager.self
                    print(error)
                }
            }
        }
    }

    @objc func didTapCreateAccount() {
        let vcSignUp = SignUpViewController()
        vcSignUp.completion = { [weak self] in
            DispatchQueue.main.async {
                let tabVC = TabBarViewController()
                tabVC.modalPresentationStyle = .fullScreen
                self?.present(tabVC, animated: true)
            }
        }
        navigationController?.pushViewController(vcSignUp, animated: true)
    }

    @objc func didTapTerms() {
        guard let url = URL(string: "https://www.eulatemplate.com/live.php?token=RLsPxkgXpniiWyNYPWeKa2mewR1GnuiE") else {
            return
        }
        let vcSF = SFSafariViewController(url: url)
        present(vcSF, animated: true)
    }

    @objc func didTapPrivacy() {
        guard let url = URL(string: "https://www.privacypolicies.com/live/dd1fde8e-ef94-48a1-8b08-49b95c29ac5e") else {
            return
        }
        let vcSF = SFSafariViewController(url: url)
        present(vcSF, animated: true)
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

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

      if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
        guard let nonce = currentNonce else {
          fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
          print("Unable to fetch identity token")
          return
        }
          print("===============\(appleIDCredential.fullName?.givenName)==================")

        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
          print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
          return
        }

        // Initialize an Apple credential with firebase.
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        // Sign in with Firebase.
          Auth.auth().signIn(with: credential) { (authResult, error) in

                          if let user = authResult?.user {
                              // create new user
                              // Sign up with authManager, upadate user 資料
                              if let fullname = appleIDCredential.fullName,
                                 let username = fullname.givenName,
                                 let email = appleIDCredential.email,
                                 let userID = Auth.auth().currentUser?.uid {

                                  var userInfo = User(userID: userID, username: username, email: email, profilePic: "", logInCount: 0)

                                  let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                  changeRequest?.displayName = username
                                  // 沒有存成功 但是也沒有印出錯誤訊息
                                  changeRequest?.commitChanges { error in
                                      if error != nil {
                                          print( Auth.auth().currentUser?.displayName)
                                      }

                                      print(error)
                                  }

                                  // for cache
                                  CacheUserInfo.shared.cache[userID] = userInfo

                                  var newAppleUser = User(userID: userID, username: username, email: email, profilePic: "")

                                  guard let appleUser = Auth.auth().currentUser else { return }
//                                  appleUser.userID = Auth.auth().currentUser?.uid
                                  DatabaseManager.shared.createUser(newUser: newAppleUser) { isSuccess in
                                      if isSuccess {
                                          print("New Apple User username in database is now \(newAppleUser.username)")

                                      } else {
                                          print("New Apple User save username to firebase error")
                                      }
                                  }
                              }

//                                     // HapticManager
                              // if sign in success, present home screen
                              let vcTabBar = TabBarViewController()
                              vcTabBar.modalPresentationStyle = .fullScreen
                              self.present(
                                  vcTabBar,
                                  animated: true,
                                  completion: nil
                              )


                              print ("Nice! You're signed in with AppleID as \(user.uid), email:\(user.email ?? "email unknow")")


                          } else {

                              print("\n\n Sign In with AppleID Error: \(error)")
                          }
                      }
          // User is signed in to Firebase with Apple.

        }
      }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
      // Handle error.
      print("Sign in with Apple errored: \(error)")
    }

}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }

}
