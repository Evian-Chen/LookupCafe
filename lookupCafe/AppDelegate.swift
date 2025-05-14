//
//  AppDelegate.swift
//  lookupCafe
//
//  Created by mac03 on 2025/5/5.
//

import UIKit
import GoogleMaps

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if let key = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String {
            GMSServices.provideAPIKey(key)
        } else {
            fatalError("Missing Google Maps API Key")
        }
        return true
    }
}
