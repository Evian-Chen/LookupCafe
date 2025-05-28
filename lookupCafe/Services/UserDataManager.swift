//
//  UserDataManager.swift
//  lookupCafe
//
//  Created by Evian on 2025/5/9.
//

import Firebase
import FirebaseFirestore
import FirebaseAuth
import Foundation

class UserDataManager: ObservableObject {
    static let shared = UserDataManager()
    
    @Published var favoritesCafes: [CafeInfoObject] = []
    @Published var email: String = "載入中..."
    @Published var createdAt: String = "載入中..."
    
    private var db = Firestore.firestore()
    private var uid: String? {
        return Auth.auth().currentUser?.uid
    }
    
    func SignInInit() {
        fetchFavorites()
        fetchUserData()
    }
    
    private init() {
        // do nothing
    }
    
    func isSignIn() -> Bool {
        if uid != nil {
            print("current user: \(uid)")
            return true
        }
        return false
    }
    
    // MARK: - 讀取使用者資料
    func fetchUserData() {
        guard let uid = uid else { return }
        db.collection("users").document(uid).getDocument { doc, error in
            if let data = doc?.data() {
                self.email = data["email"] as? String ?? "無資料"
                if let timestamp = data["createdAt"] as? Timestamp {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .short
                    self.createdAt = formatter.string(from: timestamp.dateValue())
                }
            }
        }
    }
    
    // MARK: - 讀取最愛咖啡廳
    func fetchFavorites() {
        guard let uid = uid else { return }
        let favoritesRef = db.collection("users").document(uid).collection("favorites")
        
        favoritesRef.getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                self.favoritesCafes = docs.compactMap { doc in
                    return CafeInfoObject.fromFirestore(data: doc.data(), id: doc.documentID)
                }
            }
        }
    }
    
    // MARK: - 切換最愛（加入或移除）
    func toggleFavorite(cafeObj: CafeInfoObject) {
        guard let uid = uid else {
            print("無法加入最愛，使用者未登入")
            return
        }
        
        let userRef = db.collection("users").document(uid)
        let favoriteRef = userRef.collection("favorites").document(cafeObj.id.uuidString)
        
        if isFavorite(cafeId: cafeObj.id.uuidString) {
            favoriteRef.delete()
            favoritesCafes.removeAll { $0.id == cafeObj.id }
        } else {
            let reviewDict: [[String: Any]] = cafeObj.reviews?.compactMap { review in
                return [
                    "review_time": review.review_time,
                    "reviewer_text": review.reviewer_text,
                    "reviewer_name": review.reviewer_name,
                    "reviewer_rating": review.reviewer_rating
                ]
            } ?? []
            
            let cafeData: [String: Any] = [
                "placeId": cafeObj.placeId,
                "shopName": cafeObj.shopName,
                "city": cafeObj.city,
                "district": cafeObj.district,
                "address": cafeObj.address,
                "phoneNumber": cafeObj.phoneNumber,
                "rating": cafeObj.rating,
                "services": cafeObj.services,
                "types": cafeObj.types,
                "weekdayText": cafeObj.weekdayText,
                "reviews": reviewDict,
                "latitude": cafeObj.latitude,
                "longitude": cafeObj.longitude
            ]
            favoriteRef.setData(cafeData)
            favoritesCafes.append(cafeObj)
        }
    }
    
    
    // MARK: - 判斷是否為最愛
    func isFavorite(cafeId: String) -> Bool {
        return favoritesCafes.contains { $0.id.uuidString == cafeId }
    }
}
