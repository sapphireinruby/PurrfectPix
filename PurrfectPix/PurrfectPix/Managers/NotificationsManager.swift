//
//  NotificationsManager.swift
//  PurrfectPix
//
//  Created by Amber on 11/10/21.
//

import Foundation

final class NotificationsManager {
    static let shared = NotificationsManager()

    enum PurrNotifyType: Int {
        case like = 1
        case comment = 2
        case follow = 3
    }

    private init() {}

    public func getNotifications(
        completion: @escaping ([PurrNotification]) -> Void
    ) {
        DatabaseManager.shared.getNotifications(completion: completion)
    }

    static func newIdentifier() -> String {
        // unique identifier for notification
        let date = Date()
        let number1 = Int.random(in: 0...100)
        let number2 = Int.random(in: 0...1000)
        return "\(number1)_\(number2)_\(date.timeIntervalSince1970)"
    }

    public func create(
        // create notification with unique id
        notification: PurrNotification,
        for userID: String  // change from username to ID
    ) {
        let identifier = notification.identifier
        guard let dictionary = notification.asDictionary() else {
            return
        }
        DatabaseManager.shared.insertNotification(
            identifier: identifier,
            data: dictionary,
            for: userID
        )
    }
}
