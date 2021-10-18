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

    let storage = Storage.storage()
}
