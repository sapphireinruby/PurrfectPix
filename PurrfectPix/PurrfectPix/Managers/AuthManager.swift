//
//  AuthManager.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import FirebaseAuth
import Foundation

final class AuthManager {
    // Shared instanece
    static let shared = AuthManager()

    // Private constructor
    private init() {}

    // Auth reference
    private let auth = Auth.auth()

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

    }

    // Attempt new user sign up
    // - Parameters:
    //   - email: Email
    //   - username: Username
    //   - password: Password
    //   - profilePicture: Optional profile picture data
    //   - completion: Callback
    public func signUp(
        email: String,
        username: String,
        password: String,
        profilePicture: Data?,
        completion: @escaping (Result<User, Error>) -> Void
    ){

    }
}
