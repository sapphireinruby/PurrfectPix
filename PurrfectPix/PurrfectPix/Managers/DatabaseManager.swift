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

    static let shared = DatabaseManager()

    private init() {}

    let database = Firestore.firestore()

    public func posts(
        
        for userID: String,
        completion: @escaping (Result<[Post], Error>) -> Void
    ) {
        let ref = database.collection("posts").whereField("userID", isEqualTo: userID)
            .order(by: "postedDate", descending: true) 

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

    public func singlePost(
        with postID: String,
        completion: @escaping (Post?) -> Void
    ) {
        let ref = database.collection("posts").document("\(postID)")

        ref.getDocument { snapshot, error in

            guard let data = snapshot?.data(),
            error == nil else {
                completion(nil)
                return
            }
            completion(Post(with: data))
        }
    }

// MARK: insert postCount +=1, under users
    // Create new post
    // - Parameters:
    //   - newPost: New Post model
    //   - completion: Result callback

    public func createPost(newPost: Post, completion: @escaping (Bool) -> Void) {

        guard AuthManager.shared.userID != nil else {
            completion(false)
            return
        }

        var post = newPost
        let reference = database.collection("posts").document(newPost.postID)

        do {

            try reference.setData(from: post) { error in
                if let error = error {
                    completion(false)
                } else {
                    completion(error == nil)
                }
            }
        } catch {
            print("Create post error")

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


    // userID to find user info

    public func fetchUser(
        userID: String,
        completion: @escaping (User) -> Void
    ) {
        let ref = database.collection("users").document(userID)
        ref.getDocument { snapshot, error in
            guard let snapshot = snapshot else { return }
            guard let user = User(with: snapshot.data()!) else {
                return
            }
            completion(user)
        }

    }



// MARK: Explore tab ralated:
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

            let subuser = users.filter({
                $0.username.lowercased().hasPrefix(username.lowercased())
            })
            completion(subuser)

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

    // Get posts that current user follows for home
    // - Parameters:
    //   - username: Query userID
    //   - completion: Result callback
    public func following(for userID: String, completion: @escaping ([Post]) -> Void) {

        //  1. 拿到每個following 的UserID 然後找每個posts下面 有UserID 的document
        let ref = database.collection("posts").order(by: "postedDate", descending: true)

        ref.getDocuments { snapshot, error in

            guard let posts = snapshot?.documents.compactMap({ // with extension for decode

                Post(with: $0.data())  // dictionary
            }),
            error == nil else {
                return
            }

            DatabaseManager.shared.getUserInfo(userID: userID) { user in
                var newPost = posts.filter { post in
                    if post.userID == userID {
                        return true
                    } else {
                        guard let following = user?.following else { return false }
                        if following.contains(post.userID) {
                            return true
                        } else { return false }
                    }
                }
                completion(newPost)
            }

        }
    }

    // MARK: notification related

    // Get notifications for current user
    // - Parameter completion: Result callback
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
    //   - identifer: New notification I
    //   - data: Notification data
    //   - username: target username
    public func insertNotification(
        identifier: String,
        data: [String: Any],
        for userID: String 
    ) {
        let ref = database.collection("notifications")
            .document(identifier) // an unique id for each notification
        ref.setData(data)
    }


    // Get a post from notification with id and username
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

    // MARK: insert following and followers
    // Update relationship of follow for user
    // - Parameters:
    //   - state: State to update to
    //   - targetUserID: Other user
    //   - completion: Result callback
    public func updateRelationship(state: RelationshipState, for targetUserID: String,
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

            currentFollowing.updateData([
                   "following": FieldValue.arrayRemove([targetUserID])
               ])
            do {
                try currentFollowing.setData(from: currentUserID)
            } catch {
                // error
                print("Delete target user from following list fails")
            }

            // 2. Remove currentUser from targetUser followers list, delete currentUserID from 對方的 followers, followers.remove(currentUserID)

         targetUserFollowers.updateData([
                "followers": FieldValue.arrayRemove([currentUserID])
            ])

            do {
                try targetUserFollowers.setData(from: targetUserID)
            } catch {
                // error
                print("Delete from target user's followers list fails")
            }

            completion(true)

        case .follow:
            // 1. Add target user to self's following list 加入對方到自己的 追蹤中 currentFollowing

           currentFollowing.updateData([
                   "following" : FieldValue.arrayUnion([targetUserID])
               ])
        do {
            try currentFollowing.setData(from: currentUserID)
        } catch {
            // error
            print("Follow target user fails")
        }

           // 2. Add currentUser to targetUser followers list 加入自己成對方的追蹤者 targetUserFollowers
            targetUserFollowers.updateData([
             "followers": FieldValue.arrayUnion([currentUserID])
               ])
            do {
                try targetUserFollowers.setData(from: targetUserID)
            } catch {
                // error
                print("Add to target user's followers list fails")
            }

            completion(true)
        }
    }


    // MARK: - User Info

    // Get user info
    // - Parameters
    //   - username: userID to query for
    //   - completion: Result callback
    // 應該可以所有資料 都從這個function拿
    public func getUserInfo(
        userID: String,
        completion: @escaping (User?) -> Void
    ) {
//        guard let userID = AuthManager.shared.userID else { return }
        let ref = database.collection("users").document(userID) // 過濾黑名單留言：有進來 有userID
        ref.getDocument { document, error in
            guard let document = document,
            document.exists,
            let user = try? document.data(as: User.self) else {
                print("Get user info from getUserInfo() failed")
                return
            }

            completion(user)
        }
    }

    public func setUserInfo(
        name: String,
        bio: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let userID = AuthManager.shared.userID else {
            return
        }
        let ref = database.collection("users").document(userID)
        ref.getDocument { document, error in

                 guard let document = document,
                       document.exists,
                       var user = try? document.data(as: User.self)
                 else {
                           return
                 }
                 user.username = name
                 user.bio = bio
                 do {
                    try ref.setData(from: user)
                     completion(true)
                 } catch {
                     print(error)
                     completion(error == nil)
                 }
        }
    }
    // Get user counts for target usre's fowllowers, followings, and posts
    // - Parameters:
    //   - userID: UserID to query
    //   - completion: Callback
    public func getUserCounts(
        userID: String,
        completion: @escaping ((followers: Int, following: Int, posts: Int)) -> Void
    ) {
        let docRef = database.collection("users").document(userID)

        var posts = 0
        var followers = 0
        var following = 0

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
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
        completion: @escaping (Bool) -> Void
    ){

        let ref = database.collection("posts").document(postID)
        guard let currentUserID = AuthManager.shared.userID else {
                completion(false)
                return }

            switch state {
            case .unlike:
                // 1. Remove currentUser from likers list array
                ref.updateData([
                       "likers": FieldValue.arrayRemove([currentUserID])
                   ])

                completion(true)

            case .like:
                // Add currentUser ID to the post likers list array

               ref.updateData([
                       "likers": FieldValue.arrayUnion([currentUserID])
                   ])

                completion(true)
            }
        }

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
        userID: String, // the user left comment for block list
        completion: @escaping (Bool) -> Void
    ) {
        let commentID = "\(postID)_\(comment.userID)_\(Date().timeIntervalSince1970)"
        let ref = database.collection("posts")
            .document(postID)
            .collection("comments")
            .document(commentID)
        guard let data = comment.asDictionary() else { return }
        ref.setData(data) { error in
            completion(error == nil)
        }
    }

    // Get comments for given post and filter blocklist
    // - Parameters:
    //   - postID: Post id to query
    //   - completion: Result callback
    public func getComments(
        postID: String,
        completion: @escaping (Result<[Comment], Error>) -> Void
    ) {
        let concurrentQueue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
        let semaphore = DispatchSemaphore(value: 1)

        var blockedUsers = [String]()
        concurrentQueue.async() {
              semaphore.wait()
            guard let currentUserID = AuthManager.shared.userID else { return }
            DatabaseManager.shared.getUserInfo(userID: currentUserID) { user in
                blockedUsers = user?.blocking ?? [String]()
                semaphore.signal()
            }
        }

        concurrentQueue.async() {
              semaphore.wait()
            let ref = self.database.collection("posts").document(postID).collection("comments")
            ref.getDocuments { snapshot, error in
                semaphore.signal()

                guard var comments = snapshot?.documents.compactMap({
                    Comment(with: $0.data())
                }),
                error == nil else {
                    completion(.failure(error!))
                    return
                }
                comments = comments.filter { comment in
                    if blockedUsers.contains(comment.userID) {
                        return false
                    } else {
                        return true
                    }
                }
                completion(.success(comments))
            }
            }

    }

    // check留言

    func checkComments(
        postID: String,
        completion: @escaping (Result<[Comment], Error>) -> Void
    ) {
        let group = DispatchGroup()
        var blockedUsers = [String]()

        // for block list
        guard let currentUserID = AuthManager.shared.userID else { return }

        group.enter()
        DatabaseManager.shared.getUserInfo(userID: currentUserID) { user in
            blockedUsers = user?.blocking ?? [String]()

            do {
                group.leave()
            }
        }

        group.enter()
        let ref = database.collection("posts").document(postID).collection("comments")

            ref.addSnapshotListener { snapshot, error in

            guard let snapshot = snapshot else { return }

            snapshot.documentChanges.forEach { documentChange in

                if  documentChange.type == .added {

                        ref.getDocuments() { (querySnapshot, err) in
                            guard let querySnapshot = querySnapshot else { return }

                            var comments = querySnapshot.documents.compactMap({
                                Comment(with: $0.data())
                            })

                            comments = comments.filter { comment in
                                if blockedUsers.contains(comment.userID) {
                                    return false
                                } else {
                                    return true
                                }
                            }
                            completion(.success(comments))
                        }

                    }

                }

            }
        }



    // MARK: - blocklist

    public func setBlockList(for targetUserID: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUserID = AuthManager.shared.userID else {
            completion(false)
            return
        }

        let ref = database.collection("users").document(currentUserID)

        // Add target user to self's blocking list
        ref.updateData([
            "blocking": FieldValue.arrayUnion([targetUserID]),
            "following": FieldValue.arrayRemove([targetUserID])
        ]) { error in
            if let error = error {
                print(error)
            } else {
                completion(true)
            }
        }
    }
}
