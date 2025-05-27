//
//  LocalCachManager.swift
//  lookupCafe
//
//  Created by mac03 on 2025/5/14.
//
import Foundation

class LocalCacheManager {
    static let shared = LocalCacheManager()

    private func fileURL(for category: String) -> URL {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return url.appendingPathComponent("cache_\(category).json")
    }

    // 儲存單一分類的 cafe 清單
    func saveCategory(_ category: String, data: [CafeInfoObject]) {
        do {
            let encoded = try JSONEncoder().encode(data)
            try encoded.write(to: fileURL(for: category))
            print("✅ 儲存 \(category) 快取成功")
        } catch {
            print("❌ 儲存 \(category) 快取失敗：\(error)")
        }
    }

    // 載入單一分類的 cafe 清單
    func loadCategory(_ category: String) -> [CafeInfoObject]? {
        let path = fileURL(for: category).path
        guard FileManager.default.fileExists(atPath: path) else {
            print("⚠️ 快取檔不存在：\(category)")
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL(for: category))
            let decoded = try JSONDecoder().decode([CafeInfoObject].self, from: data)
            print("✅ 已讀取 \(category) 快取，筆數：\(decoded.count)")
            return decoded
        } catch {
            print("❌ 無法讀取 \(category) 快取：\(error)")
            return nil
        }
    }

    // 清除單一分類的快取
    func clearCategory(_ category: String) {
        let path = fileURL(for: category).path
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(at: fileURL(for: category))
                print("🗑️ 已清除 \(category) 快取")
            } catch {
                print("❌ 清除 \(category) 快取失敗：\(error)")
            }
        }
    }

    // 清除所有分類的快取（需傳入所有分類）
    func clearAllCategories(_ categories: [String]) {
        for category in categories {
            clearCategory(category)
        }
    }

    // 批次儲存所有分類
    func saveAll(categories: [String: [CafeInfoObject]]) {
        for (category, data) in categories {
            saveCategory(category, data: data)
        }
    }

    // 批次讀取所有分類
    func loadAll(_ categoryList: [String]) -> [String: [CafeInfoObject]] {
        var result: [String: [CafeInfoObject]] = [:]

        for category in categoryList {
            if let data = loadCategory(category) {
                result[category] = data
            }
        }

        return result
    }
}
