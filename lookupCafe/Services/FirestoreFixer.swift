//
//  FirestoreFixer.swift
//  lookupCafe
//
//  Created by mac03 on 2025/5/13.
//

import Foundation
import FirebaseFirestore

class FirestoreFixer {
    let db = Firestore.firestore()

    /// 讀入 cityDistricts JSON 並解析為 [String: [String]]
    func loadCityDistricts() -> [String: [String]] {
        guard let url = Bundle.main.url(forResource: "city_district", withExtension: "json") else {
            print("❌ 找不到 city-district.json")
            return [:]
        }
        do {
            let data = try Data(contentsOf: url)
            let cityDict = try JSONDecoder().decode([String: [String]].self, from: data)
            return cityDict
        } catch {
            print("❌ 無法解析 city-district.json：\(error)")
            return [:]
        }
    }

    /// 幫指定分類下的每個城市補上 exists 欄位
    func fixEmptyCityDocuments(for categoryName: String, cityDistricts: [String: [String]]) async {
        let categoryRef = db.collection(categoryName)

        for city in cityDistricts.keys {
            let docRef = categoryRef.document(city)
            do {
                try await docRef.setData(["exists": true], merge: true)
                print("✅ 補上 \(categoryName)/\(city)")
            } catch {
                print("❌ 無法補上 \(categoryName)/\(city)：\(error)")
            }
        }
    }

    /// 支援一次處理多個分類
    func fixAllCategories(categories: [String]) async {
        let cityDistricts = loadCityDistricts()
        for category in categories {
            await fixEmptyCityDocuments(for: category, cityDistricts: cityDistricts)
        }
    }
}
