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

    static let shared = DatabaseManager()  //singleton
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

        ref.getDocuments { snapshot, error in

            guard let posts = snapshot?.documents.compactMap({

                Post(with: $0.data())
            }),
            error == nil else {
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

    // Create new post
    // - Parameters:
    //   - newPost: New Post model
    //   - completion: Result callback

    public func createPost(newPost: Post, completion: @escaping (Bool) -> Void) {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            completion(false)
            return
        }

        var post = newPost
        let reference = database.collection("posts").document()
        let id = reference.documentID
        post.postID = id

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



    //edit with Elio
//    public func createPost(newPost: Post, completion: @escaping (Result<String, Error>) -> Void) {
//        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
//            print("")
//            return }
//        var post = newPost
//        let reference = database.collection("posts").document()
//        let id = reference.documentID
//        post.postID = id
//
//        do {
//
//            try reference.setData(from: post) { err in
//                if let err = err {
//                    completion(.failure(err))
//                }else{
//                    completion(.success("Sucess"))
//                }
//            }
//        } catch {
//
//        }
//    }

    
}
