//
//  AnalyticsManager.swift
//  PurrfectPix
//
//  Created by Amber on 10/18/21.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsManager {

    static let shared = AnalyticsManager()  //singleton

    private init() {}

    func logEvent() {
        Analytics.logEvent("", parameters: [:])
    }  //no need for instance, will use logEvent later
    //Analytics.logEvent(<#T##name: String##String#>, parameters: <#T##[String : Any]?#>)
}
