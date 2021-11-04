//
//  DataManager.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

final class DatabaseManager {

    static let shared = DatabaseManager()  // singleton
    // Private constructor
    private init() {}

    let database = Firestore.firestore()

    // Find posts from a given user
    // - Parameters:
    // - username: UserID ** to query
    // - completion: Result callback

    public func posts(
        
        for userID: String,
        completion: @escaping (Result<[Post], Error>) -> Void
    ) {
        let ref = database.collection("posts").whereField("userID", isEqualTo: userID)
            .order(by: "postedDate", descending: true)  //  只有userID, 沒有username

        ref.getDocuments { snapshot, error in

            guard let posts = snapshot?.documents.compactMap({ // with extension for decode

                Post(with: $0.data())  // dictionary
            }),
            error == nil else {
                completion(.failure(error!))
                return
            }
            completion(.success(posts))
        }
    }

// edit with Elio
//    public func posts(
//        for username: String,
//        completion: @escaping (Result<[Post], Error>) -> Void
//    )
//

//    {
//        let ref = database.collection("users")
//            .document(username)
//            .collection("posts")
//        ref.getDocuments { snapshot, error in
//            guard let posts = snapshot?.documents.compactMap({
//                // decode post document 才能排序,可以直接.order by date
//                // https://firebase.google.com/docs/firestore/query-data/order-limit-data
//
//                Post(with: $0.data())
//            }).sorted(by: {
//                return $0.date > $1.date
//            }),
//            error == nil else {
//                return
//            }
//            completion(.success(posts))
//        }
//    }


    // MARK: Search under Explore VC: Find user with username
    // - Parameters:
    //   - username: Source username
    //   - completion: Result callback
    public func findUsers(
        with usernamePrefix: String,
        completion: @escaping ([User]) -> Void) {

        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }),
                  error == nil else {
                completion([])
                return
            }

            let subuset = users.filter({
                $0.username.lowercased().hasPrefix(usernamePrefix.lowercased())
            })
            completion(subuset)
        }
    }

    // Create new post
    // - Parameters:
    //   - newPost: New Post model
    //   - completion: Result callback

    public func createPost(newPost: Post, completion: @escaping (Bool) -> Void) {

        guard let userID = AuthManager.shared.userID else {
            completion(false)
            return
        }

        var post = newPost
        let reference = database.collection("posts").document(newPost.postID)

        do {

            try reference.setData(from: post) { err in
                if let err = err {
                    completion(false)
                } else {
                    completion(err == nil)
                }
            }
        } catch {

        }
    }

    // Create new user
    // - Parameters:
    //   - newUser: User model
    //   - completion: Result callback

    public func createUser(newUser: User, completion: @escaping (Bool) -> Void) {

        let reference = database.collection("users").document(newUser.userID)

        guard let data = newUser.asDictionary() else {  // 不能asDictionary 應該要改
            completion(false)
            return
        }
        reference.setData(data) { error in
            completion(error == nil)
        }
    }

    // Get a post with id and username
    // - Parameters:
    //   - identifer: Query id
    //   - username: Query username
    //   - completion: Result callback
    public func getPost(
        with identifer: String,
        from username: String,
        completion: @escaping (Post?) -> Void
    ) {
        let ref = database.collection("users")
            .document(username)
            .collection("posts")
            .document(identifer)
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  error == nil else {
                completion(nil)
                return
            }

            completion(Post(with: data))
        }
    }

    // Find single user with email
    // - Parameters:
    //   - email: Source email
    //   - completion: Result callback
    
    public func findUser(with email: String, completion: @escaping (User?) -> Void) {
        
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }),
                  error == nil else {
                completion(nil)
                return
            }

            let user = users.first(where: { $0.email == email })
            completion(user)
        }
    }

    // Get users that parameter username follows
    // - Parameters:
    //   - username: Query usernam
    //   - completion: Result callback
    public func following(for username: String, completion: @escaping ([String]) -> Void) {
        
        let ref = database.collection("users")
            .document(username)
            .collection("following")
        ref.getDocuments { snapshot, error in
            guard let usernames = snapshot?.documents.compactMap({ $0.documentID }), error == nil else {
                completion([])
                return
            }
            completion(usernames)
        }
    }

    // MARK: - Liking

    // Like states that are supported
    enum LikeState {
        case like
        case unlike
    }

    // Update like state on post
    // - Parameters:
    //   - state: State to update to
    //   - postID: Post to update for
    //   - owner: Owner username of post
    //   - completion: Result callback
    public func updateLikeState(
        state: LikeState,
        postID: String,
        owner: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        let ref = database.collection("users")
            .document(owner)
            .collection("posts")
            .document(postID)
        getPost(with: postID, from: owner) { post in
            guard var post = post else {
                completion(false)
                return
            }

            switch state {
            case .like:
                if !post.likers.contains(currentUsername) {
                    // only append user if the user is not already likes the post, to avoid double users in arrayㄍ
                    post.likers.append(currentUsername)
                }
            case .unlike:
                post.likers.removeAll(where: { $0 == currentUsername })
            }

            guard let data = post.asDictionary() else {
                completion(false)
                return
            }
            ref.setData(data) { error in
                completion(error == nil)
            }
        }
    }
    
}
