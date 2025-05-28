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
    @State private var isAnimating = false

    var body: some View {
        VStack {
            Image("LoadingIcon")
                .resizable()
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }

            Text("資料載入中，請稍候...")
        }
    }
}


struct ContentView: View {
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
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2秒
            await categoryManager.asyncInit()
            await MainActor.run {
                appState.isReady = true
            }
        }
    }
}
