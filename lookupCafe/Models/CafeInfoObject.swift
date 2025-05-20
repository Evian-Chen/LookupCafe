//
//  CafeInfoObject.swift
//  lookupCafe
//
//  Created by mac03 on 2025/4/21.
//

import Foundation

// 這個struct包含了要顯示出的咖啡廳的重要資訊
struct CafeInfoObject: Codable, Identifiable {
    var id = UUID()  // no need to add \.self when ForEach
    
    var placeId: String?
    var shopName: String
    var city: String
    var district: String
    var address: String
    var phoneNumber: String
    
    // 評論等使用者點入之後再把資料抽出來，或者直接再用一次google API
    var rating: Int
    var services: [Bool]
    
    // 關鍵字
    var types: [String]
    
    // 營業時間
    var weekdayText: [String]
    
    var reviews: [Review]?
    
    var latitude: Double?
    var longitude: Double?
}

extension CafeInfoObject {
    static func fromFirestore(data: [String: Any], id: String) -> CafeInfoObject? {
        guard let uuid = UUID(uuidString: id) else { return nil }
        
        let reviewDicts = data["reviews"] as? [[String: Any]]
        let reviews: [Review]? = reviewDicts?.compactMap { dict in
            guard let time = dict["review_time"] as? String,
                  let name = dict["reviewer_name"] as? String,
                  let rating = dict["reviewer_rating"] as? Int,
                  let text = dict["reviewer_text"] as? String else {
                return nil
            }
            return Review(
                review_time: time,
                reviewer_name: name,
                reviewer_rating: rating,
                reviewer_text: text
            )
        }
        
        return CafeInfoObject(
            id: uuid,
            placeId: data["place_id"] as? String ?? "noPlaceId",
            shopName: data["shopName"] as? String ?? "",
            city: data["city"] as? String ?? "",
            district: data["district"] as? String ?? "",
            address: data["address"] as? String ?? "",
            phoneNumber: data["phoneNumber"] as? String ?? "",
            rating: data["rating"] as? Int ?? 0,
            services: data["services"] as? [Bool] ?? [],
            types: data["types"] as? [String] ?? [],
            weekdayText: data["weekdayText"] as? [String] ?? [],
            reviews: reviews,
            latitude: data["latitude"] as? Double ?? 0.0,
            longitude: data["longitude"] as? Double ?? 0.0
        )
    }
}

struct Review: Codable, Identifiable {
    var id = UUID()
    
    var review_time: String
    var reviewer_name: String
    var reviewer_rating: Int
    var reviewer_text: String
}

