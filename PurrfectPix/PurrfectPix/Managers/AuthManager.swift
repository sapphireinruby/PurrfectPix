//
//  AuthManager.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import FirebaseAuth
import Foundation

// Object to manage authentication
final class AuthManager {
    
    // Shared instanece
    static let shared = AuthManager()

    // Private constructor
    private init() {}

    // Auth reference
    private let auth = Auth.auth()

    // Auth errors that can occur
    enum AuthError: Error {

        case newUserCreation
        case signInFailed
    }

    // Determine if user is signed in
    public var isSignedIn: Bool {

        return auth.currentUser != nil
    }

    // Attempt sign in
    // - Parameters:
    //   - email: Email of user
    //   - password: Password of user
    //   - completion: Callback

    public func signIn(
        email: String,
        password: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        DatabaseManager.shared.findUser(with: email) { [weak self] user in
            guard let user = user else {
                completion(.failure(AuthError.signInFailed))
                return
            }

            self?.auth.signIn(withEmail: email, password: password) { result, error in
                guard result != nil, error == nil else {
                    
                    completion(.failure(AuthError.signInFailed))
                    return
                }

                UserDefaults.standard.setValue(user.userID, forKey: "userID")
                UserDefaults.standard.setValue(user.email, forKey: "email")
                completion(.success(user))
            }
        }
    }

    // Attempt new user sign up
    // - Parameters:
    //   - email: Email
    //   - username: Username
    //   - password: Password
    //   - profilePicture: Optional profile picture data
    //   - completion: Callback
    
    public func signUp(

        userID: String,
        email: String,
        username: String,
        password: String,
        profilePicture: Data?,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        let newUser = User(userID: userID, username: username, email: email, profilePic: "", followingUsers: [String](), logInCount: 0)

        // Create account
        auth.createUser(withEmail: email, password: password) { result, error in
            guard result != nil, error == nil else {
                completion(.failure(AuthError.newUserCreation))
                return
            }

            DatabaseManager.shared.createUser(newUser: newUser) { success in
                if success {
                    StorageManager.shared.uploadProfilePicture(

                        userID: userID,
                        username: username,
                        data: profilePicture
                    ) { uploadSuccess in
                        if uploadSuccess {
                            completion(.success(newUser))
                        }
                        else {
                            completion(.failure(AuthError.newUserCreation))
                        }
                    }
                }
                else {
                    completion(.failure(AuthError.newUserCreation))
                }
            }
        }
    }

    // Attempt Sign Out
    // - Parameter completion: Callback upon sign out
    public func signOut(
        completion: @escaping (Bool) -> Void
    ) {
        do {
            try auth.signOut()
            completion(true)
        }
        catch {
            print(error)
            completion(false)
        }
    }
}
