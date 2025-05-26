//
//  ContentView.swift
//  lookupCafe
//
//  Created by mac03 on 2025/4/4.
//

import SwiftUI

struct TabItemView: View {
    var obj: TabItemObj
    
    var body: some View {
        VStack {
            obj.image
            obj.text
        }
    }
}


struct LoadingView: View {
    @State private var rotate = false

    var body: some View {
        VStack {
            Image("LoadingIcon")
                .resizable()
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(rotate ? 10 : -10))
                .animation(
                    Animation.easeInOut(duration: 1).repeatForever(autoreverses: true),
                    value: rotate
                )
                .onAppear {
                    rotate = true
                }

            Text("第一次啟動需要載入資料")
            Text("約花費三到五分鐘，請稍候...")
                .padding()
        }
    }
}

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @EnvironmentObject var appState: AppState

    @StateObject var authViewModel = AuthViewModel()
    @StateObject var categoryManager = CategoryManager()

    var body: some View {
        Group {
            if appState.isReady {
                TabView {
                    RecommendView(categoryManager: categoryManager)
                        .tabItem { TabItemView(obj: .recommend) }
                        .environmentObject(categoryManager)
                        .environmentObject(LocationDataManager())

                    MapView()
                        .tabItem { TabItemView(obj: .map) }
                        .environmentObject(LocationDataManager())

                    ProfileView()
                        .tabItem { TabItemView(obj: .profile) }
                        .environmentObject(AuthViewModel())
                }
            } else {
                LoadingView()
            }
        }
        .task {
            await categoryManager.asyncInit()
            await MainActor.run {
                appState.isReady = true
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
