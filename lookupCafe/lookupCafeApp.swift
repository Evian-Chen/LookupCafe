//
//  lookupCafeApp.swift
//  lookupCafe
//
//  Created by mac03 on 2025/4/4.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class AppState: ObservableObject {
    @Published var isReady = false
}

@main
struct lookupCafeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var locationManager = LocationDataManager()
    @StateObject var appState = AppState()

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        _ = UserDataManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(appState)
        }
    }
}

