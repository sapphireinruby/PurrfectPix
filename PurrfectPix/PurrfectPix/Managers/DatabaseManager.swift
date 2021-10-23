//
//  DataManager.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import FirebaseFirestore
import Foundation

final class DatabaseManager {

    static let shared = DatabaseManager()  //singleton

    private init() {}

    let database = Firestore.firestore()
}
