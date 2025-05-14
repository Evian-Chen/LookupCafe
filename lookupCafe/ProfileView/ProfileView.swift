//
//  ProfileView.swift
//  lookupCafe
//
//  Created by mac03 on 2025/4/9.
//

import SwiftUI
import FirebaseAuth


struct SettingsView: View {
    var body: some View {
        Text("SettingsView")
    }
}

struct LogOutView: View {
    @State private var showingAlert = false
    var authViewModel: AuthViewModel
    
    var body: some View {
        Button {
            showingAlert.toggle()
        } label: {
            Text("登出")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 50)
        }
        .alert("確定要登出嗎？", isPresented: $showingAlert) {
            Button("取消", role: .cancel) { showingAlert.toggle() }
            Button("確定", role: .destructive) {
                authViewModel.SignOutGoogle()
            }
        }
    }
}

struct SignedInView: View {
    // 已經登入的user資料
    var authViewModel: AuthViewModel
    
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
                
                ForEach(ProfileData.allCases, id: \.self) { dataCase in
                    dataCase.ButtonView
                }
                
                // 登出按鍵額外設定
                LogOutView(authViewModel: authViewModel)
            } // vstack
        }
    }
}

// 還沒登入時的View
struct NotSignedInView: View {
    var authViewModel: AuthViewModel
    
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
        if authViewModel.isSignedIn {
                        SignedInView(authViewModel: authViewModel)
        } else  { // 未登入
            NotSignedInView(authViewModel: authViewModel)
        } // not signed in
    }
}

#Preview {
    SignedInView(authViewModel: AuthViewModel())
}
