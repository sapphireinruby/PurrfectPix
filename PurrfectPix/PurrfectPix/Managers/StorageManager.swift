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

//    let storage = Storage.storage() edit with Elio

    // Upload post image
    // - Parameters:
    //   - data: Image data
    //   - id: New post id
    //   - completion: Result callback

    public func uploadPost(  // image 

        data: Data?,
        id: String, // the id create at caption vc, for image to storage
        completion: @escaping (URL?) -> Void
    ) {
        guard let username = UserDefaults.standard.string(forKey: "username"),
              let data = data else {
            return
        }
        let ref = storage.child("\(username)/posts/\(id).png")
        ref.putData(data, metadata: nil) { _, error in
            ref.downloadURL { url, _ in
                completion(url)
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
