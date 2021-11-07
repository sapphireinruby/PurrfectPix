//
//  StorageManager.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import Foundation
import FirebaseStorage

final class StorageManager {

    static let shared = StorageManager()  //singleton

    private init() {}

    private let storage = Storage.storage().reference()

    public func uploadPost(  // image 

        data: Data?,
        userID: String,
        postID: String, // the postID create at caption vc, for image to storage
        completion: @escaping (URL?) -> Void
    ) {
              guard let data = data else {
            return
        }
        let ref = storage.child("\(userID)/posts/\(postID).png")
        ref.putData(data, metadata: nil) { _, error in
            ref.downloadURL { url, _ in
                completion(url) // the download url we just uploaded
            }
        }
    }

    public func downloadURL(for post: Post, completion: @escaping (URL?) -> Void) {

        guard let ref = post.storageReference else {

            completion(nil)
            return
        }

        storage.child(ref).downloadURL { url, _ in // ignore error
            completion(url)
        }
    }

    public func profilePictureURL(for userID: String, completion: @escaping (URL?) -> Void) {
        storage.child("\(userID)/profile_picture.png").downloadURL { url, _ in
            completion(url)
        }
    }

    public func uploadProfilePicture(

        userID: String,
        data: Data?,
        completion: @escaping (Bool) -> Void
    ) {
        guard let data = data else {
            return
        }
        storage.child("\(userID)/profile_picture.png").putData(data, metadata: nil) { _, error in
            completion(error == nil)
        }
    }

// edit with Elio
//    public func uploadPost(
//
//        data: Data?,
//        id: String,  // the id create at caption vc, for image to storage
//        completion: @escaping (URL?) -> Void
//    ) {
//        guard let username = UserDefaults.standard.string(forKey: "username"),
//              let data = data else {
//            return
//        }
//        // if firebase storage: username/png
//
//        let ref = storage.child("\(username)/posts/\(id).png")
//        ref.putData(data, metadata: nil) { _, error in
//            ref.downloadURL { url, _ in
//                completion(url)
//            }
//        }
//    }
}
