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

    // MARK: Search under Explore VC: Find user with username
    // - Parameters:
    //   - username: Source username
    //   - completion: Result callback
    public func findUsers(
        username: String,
        completion: @escaping ([User]) -> Void) {

        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }),
                  error == nil else {
                completion([])
                return
            }

            let subuset = users.filter({
                $0.username.lowercased().hasPrefix(username.lowercased())
            })
            completion(subuset)
//
//
//            let user = users.first(
//                // 邏輯要改
//                where: { $0.username == username })
//            completion([user])
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

    // Gets posts for explore page
    // - Parameter completion: Result callback

    public func explorePosts(completion: @escaping ([Post]) -> Void) {

        let ref = database.collection("posts") // get all posts from database

        // 以下簡易版
        ref.getDocuments { snapshot, error in

            guard let posts = snapshot?.documents.compactMap({ // with extension for decode

                Post(with: $0.data())  // dictionary
            }),
            error == nil else {
//                completion(false)
                return
            }
            completion(posts)
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
    //   - username: Query username
    //   - completion: Result callback
    public func following(for userID: String, completion: @escaping ([String]) -> Void) {
        
        let ref = database.collection("users")
            .document(userID)
            .collection("following")
        ref.getDocuments { snapshot, error in
            guard let username = snapshot?.documents.compactMap({ $0.documentID }), error == nil else {
                completion([])
                return
            }
            completion(username)
        }
    }


    // MARK: notification related

    /// Get notifications for current user
    /// - Parameter completion: Result callback
    public func getNotifications(
        completion: @escaping ([PurrNotification]) -> Void
    ) {
        guard let currentUserID = AuthManager.shared.userID else {
            // change username to userID
            completion([])
            return
        }
        let ref = database.collection("notifications").whereField("targetUserID", isEqualTo: currentUserID)
        ref.getDocuments { snapshot, error in
            guard let notifications = snapshot?.documents.compactMap({
                PurrNotification(with: $0.data()) // codeble
            }),
            error == nil else {
                completion([])
                return
            }

            completion(notifications)
        }
    }

    // Creates new notification
    // - Parameters:
    ///   - identifer: New notification I
    //   - data: Notification data
    //   - username: target username
    public func insertNotification(
        identifier: String,
        data: [String: Any],
        for userID: String // from name to ID
    ) {
        let ref = database
            .collection("notifications")
            .document(identifier) // an unique string for each notification
        ref.setData(data)
    }


    // Get a post with id and username
    // - Parameters:
    //   - identifier: Query id
    //   - username: Query username
    //   - completion: Result callback
    public func getPost(
        with identifier: String,
        completion: @escaping (Post?) -> Void  // Post model
    ) {
        let ref = database.collection("notification")
            .document(identifier)
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  error == nil else {
                completion(nil)
                return
            }

            completion(Post(with: data))
        }
    }

    // Follow states
    enum RelationshipState {
        case follow
        case unfollow
    }

    // Update relationship of follow for user
    // - Parameters:
    //   - state: State to update to
    //   - targetUsername: Other user username
    //   - completion: Result callback
    public func updateRelationship(user: User,
        state: RelationshipState,
        for targetUserID: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUserID = AuthManager.shared.userID else {
            completion(false)
            return
        }

        let currentFollowing = database.collection("users")
            .document(currentUserID) // 自己的

        let targetUserFollowers = database.collection("users")
            .document(targetUserID) // 對方的

        switch state {
        case .unfollow:
            // 1. Remove follower for currentUser following list, delete targetUserID from 自己的 following array

//            if following.contains(targetUserID) {
//
//            let index = following.firstIndex(of: following)
////                following.remove(at: index!)
//            }
//
//                let user = User(userID: user.userID, username: user.username, email: user.email, profilePic: user.profilePic, following: user.following?.remove(at: index), followers: user.followers, logInCount: user.logInCount)

            currentFollowing.updateData([
                   "following" : FieldValue.arrayRemove(["targetUserID"])
               ])

            do {
                try currentFollowing.setData(from: user)
            } catch {
                // error
                print("Delete target user from following list fails")
            }

            // 2. Remove currentUser from targetUser followers list, delete currentUserID from 對方的 followers, followers.remove(currentUserID)

         targetUserFollowers.updateData([
                "followers" : FieldValue.arrayRemove(["currentUserID"])
            ])


            do {
                try targetUserFollowers.setData(from: user)
            } catch {
                // error
                print("Delete from target user's followers list fails")
            }

            completion(true)

        case .follow:
            // 1. Add target user to self's following list 加入對方到自己的 追蹤中 currentFollowing


            currentFollowing.updateData([
                   "followers" : FieldValue.arrayUnion(["targetUserID"])
               ])

        do {
            try currentFollowing.setData(from: user)
        } catch {
            // error
            print("Follow target user fails")
        }


           // 2. Add currentUser to targetUser followers list 加入自己成對方的追蹤者 targetUserFollowers

            targetUserFollowers.updateData([
                   "followers" : FieldValue.arrayUnion(["currentUserID"])
               ])

            do {
                try targetUserFollowers.setData(from: user)
            } catch {
                // error
                print("Add to target user's followers list fails")
            }

            completion(true)
        }
    }

    // Get user counts for target usre
    // - Parameters:
    //   - userID: UserID to query
    //   - completion: Callback
    public func getUserCounts(
        userID: String,
        completion: @escaping ((followers: Int, following: Int, posts: Int)) -> Void
    ) {
        let userRef = database.collection("users")
            .document(userID)

        var followers = 0
        var following = 0
        var posts = 0

        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()

        userRef.collection("posts").getDocuments { snapshot, error in
            defer {
                group.leave()
            }

            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            posts = count
        }

        userRef.collection("followers").getDocuments { snapshot, error in
            defer {
                group.leave()
            }

            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            followers = count
        }

        userRef.collection("following").getDocuments { snapshot, error in
            defer {
                group.leave()
            }

            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            following = count
        }

        group.notify(queue: .global()) {
            let result = (
                followers: followers,
                following: following,
                posts: posts
            )
            completion(result)
        }
    }

    // Check if current user is following another
    // - Parameters:
    //   - targetUsername: Other user to check
    //   - completion: Result callback
    public func isFollowing(
        targetUserID: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = AuthManager.shared.username else {
            completion(false)
            return
        }

        let ref = database.collection("users")
            .document(targetUserID)
            .collection("followers")
            .document(currentUsername) // 在post下面 顯示有按讚的人名
        ref.getDocument { snapshot, error in
            guard snapshot?.data() != nil, error == nil else {
                // Not following
                completion(false)
                return
            }
            // following
            completion(true)
        }
    }

    // Get followers for user
    // - Parameters:
    //   - username: Username to query
    //   - completion: Result callback
    public func followers(for userID: String, completion: @escaping ([String]) -> Void) {
        let ref = database.collection("users")
            .document(userID)
            .collection("followers")
        ref.getDocuments { snapshot, error in
            guard let usernames = snapshot?.documents.compactMap({ $0.documentID }), error == nil else {
                completion([])
                return
            }
            completion(usernames)  //  確認是否username可以
        }
    }

    // MARK: - User Info

    // Get user info
    // - Parameters:
    //   - username: username to query for
    //   - completion: Result callback
//    public func getUserInfo(
//        username: String,
//        completion: @escaping (UserInfo?) -> Void
//    ) {
//        let ref = database.collection("users")
//            .document(username)
//            .collection("information")
//            .document("basic")
//        ref.getDocument { snapshot, error in
//            guard let data = snapshot?.data(),
//                  let userInfo = UserInfo(with: data) else {
//                completion(nil)
//                return
//            }
//            completion(userInfo)
//        }
//    }

    // Set user info
    // - Parameters:
    //   - userInfo: UserInfo model
    //   - completion: Callback
//    public func setUserInfo(
//        userInfo: UserInfo,
//        completion: @escaping (Bool) -> Void
//    ) {
//        guard let username = UserDefaults.standard.string(forKey: "username"),
//              let data = userInfo.asDictionary() else {
//            return
//        }
//
//        let ref = database.collection("users")
//            .document(username)
//            .collection("information")
//            .document("basic")
//        ref.setData(data) { error in
//            completion(error == nil)
//        }
//    }

    // MARK: - Comment

    // Create a comment
    // - Parameters:
    //   - comment: Comment mmodel
    //   - postID: post id
    //   - owner: username who owns post
    //   - completion: Result callback
    public func createComments(
        comment: Comment,
        postID: String,
        owner: String,
        completion: @escaping (Bool) -> Void
    ) {
        let newIdentifier = "\(postID)_\(comment.username)_\(Date().timeIntervalSince1970)_\(Int.random(in: 0...1000))"
        let ref = database.collection("posts")
            .document(postID)
            .collection("comments")
            .document(newIdentifier)
        guard let data = comment.asDictionary() else { return }
        ref.setData(data) { error in
            completion(error == nil)
        }
    }

    // Get comments for given post
    // - Parameters:
    //   - postID: Post id to query
    //   - owner: Username who owns post
    //   - completion: Result callback
    public func getComments(
        postID: String,
        owner: String,
        completion: @escaping ([Comment]) -> Void
    ) {
        let ref = database.collection("users")
            .document(owner)
            .collection("posts")
            .document(postID)
            .collection("comments")
        ref.getDocuments { snapshot, error in
            guard let comments = snapshot?.documents.compactMap({
                Comment(with: $0.data())
            }),
            error == nil else {
                completion([])
                return
            }

            completion(comments)
        }
    }

    // MARK: - Liking

    // two like states
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
        guard let currentUserID =  AuthManager.shared.userID else { return }
        let ref = database.collection("posts")
            .document(postID)
        getPost(with: postID) { post in
            guard var post = post else {
                completion(false)
                return
            }

            switch state {
            case .like:
                if !post.likers.contains(currentUserID) {
                    post.likers.append(currentUserID)
                }
            case .unlike:
                post.likers.removeAll(where: { $0 == currentUserID })
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
