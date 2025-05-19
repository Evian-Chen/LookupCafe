//
//  ProfileView.swift
//  lookupCafe
//
//  Created by mac03 on 2025/4/9.
//

import SwiftUI
import FirebaseAuth


struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showingAlert = false
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Toggle("Dark Mode", isOn: $isDarkMode)
                
                // 登出
                Button {
                    showingAlert.toggle()
                } label: {
                    Text("登出")
                }
                
                Text("[查看原始碼](https://github.com/Evian-Chen/LookupCafe)")
            }
        }
        .navigationTitle("Settings")
        .alert("確定要登出嗎？", isPresented: $showingAlert) {
            Button("取消", role: .cancel) { showingAlert.toggle() }
            Button("確定", role: .destructive) {
                authViewModel.SignOutGoogle()
            }
        }
    }
}

struct SignedInView: View {
    @ObservedObject var user = UserDataManager.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Profile")
                    .font(.largeTitle).bold()
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.bottom, 20)
                
                Text("Email: \(user.email)")
                
                Form {
                    NavigationLink {
                        MyFovoriteView()
                    } label: {
                        Text("我的最愛")
                    }
                    
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Text("設定")
                    }
                }
            } // vstack
        }
    }
}

// 還沒登入時的View
struct NotSignedInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                
                Text("尚未登入")
                    .font(.title2)
                    .bold()
                
                Text("登入以使用完整功能，包括收藏與評論")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button {
                    authViewModel.SignInByGoogle()
                } label: {
                    Text("Sign in by Google")
                        .padding(10)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(7)
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        // 已經登入
        if !authViewModel.didCheckedUser {
            Text("載入中...")
        } else {
            if authViewModel.isSignedIn {
                SignedInView()
                    .onAppear {
                        print(authViewModel.currentUser?.email ?? "not sign in")
                    }
            } else  { // 未登入
                NotSignedInView()
            } // not signed in
        }
    }
}

