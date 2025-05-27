//
//  AppDelegate.swift
//  lookupCafe
//
//  Created by mac03 on 2025/5/5.
//

import UIKit
import GoogleMaps
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // 提供 Google Maps API 金鑰
        if let key = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String {
            GMSServices.provideAPIKey(key)
        } else {
            fatalError("Missing Google Maps API Key")
        }

        // Firebase 日誌等級
//        FirebaseConfiguration.shared.setLoggerLevel(.debug)

        // 初始化 Firebase
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        // 設定 Firestore 快取大小
        let settings = Firestore.firestore().settings
        
        // 不寫入disk，因為有把資料用json存到本地沙盒
        settings.cacheSettings = MemoryCacheSettings()
        Firestore.firestore().settings = settings
        settings.isSSLEnabled = true
        settings.host = "firestore.googleapis.com"

        return true
    }
}
