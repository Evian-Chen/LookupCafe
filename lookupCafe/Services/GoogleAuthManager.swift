//
//  GoogleAuthManager.swift
//  lookupCafe
//
//  Created by mac03 on 2025/4/22.
//

import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import SwiftUICore

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isSignedIn: Bool = false
    
    @Published var didCheckedUser: Bool = false
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                self.currentUser = user
                self.isSignedIn = user != nil
                self.setupUserDocument()
                self.didCheckedUser = true
                
                // 這邊是更新「現在的使用者」的相關資料給UserDataManager，因為之後的資料操作是由UserDataManager處理
                UserDataManager.shared.SignInInit()
                print("使用者狀態更新：\(self.currentUser?.email ?? "未登入")")
            }
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func SignInByGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController
        else {
            print("There is no root view controller!")
            return
        }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] result, error in
            if let err = error{
                print("sign in error: \(err)")
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }
            
            // 憑證
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                if let err = error {
                    print("sign in error: \(err)")
                    return
                }
                
                // 成功登入
                DispatchQueue.main.async {
                    self.currentUser = result?.user
                    self.isSignedIn = true
                    
                    // load in 目前的登入者的資料庫
                    self.setupUserDocument()
                    
                    UserDataManager.shared.SignInInit()
                }
            }
            
        }
    } // sign in
    
    func SignOutGoogle() {
        let firebaseAuth = Auth.auth()
        do {
            self.isSignedIn = false
            try firebaseAuth.signOut()
            self.currentUser = nil
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    } // sign out
    
    func setupUserDocument() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { doc, error in
            if let doc = doc, doc.exists {
                print("使用者存在，不用新增使用者")
            } else {
                let userData: [String: Any] = [
                    "email": user.email ?? "",
                    "createdAt": FieldValue.serverTimestamp(),
                    "favoritesIds": [],
                    "favoritesCafeData": [:]
                ]
                userRef.setData(userData) { error in
                    if let error = error {
                        print("插入第一筆使用者資料時出錯：\(error)")
                    } else {
                        print("成功插入第一筆使用者資料")
                    }
                }
            }
        }
    }
}
