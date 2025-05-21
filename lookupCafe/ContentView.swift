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

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    // 呼叫物件去管理城市行政區的資料
//    @StateObject var cityDistrictManager = LocationDataManager()
    
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var categoryManager = CategoryManager()
    
    @State private var city = ""
    @State private var district = ""
    
    var body: some View {
        TabView {
            RecommendView(categoryManager: categoryManager)
                .tabItem{ TabItemView(obj: .recommend) }
                .environmentObject(categoryManager)
                .environmentObject(LocationDataManager())
            
            MapView()
                .tabItem{ TabItemView(obj: .map) }
                .environmentObject(LocationDataManager())
            
            ProfileView()
                .tabItem{ TabItemView(obj: .profile) }
                .environmentObject(AuthViewModel())
        }
        .task {
            await categoryManager.asyncInit()
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

//#Preview {
//    ContentView()
//}
