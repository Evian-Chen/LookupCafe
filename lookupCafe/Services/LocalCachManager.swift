//
//  LocalCachManager.swift
//  lookupCafe
//
//  Created by mac03 on 2025/5/14.
//

import Foundation

class LocalCacheManager {
    static let shared = LocalCacheManager()

    private let fileName = "cachedCafeData.json"

    private var fileURL: URL {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return url.appendingPathComponent(fileName)
    }

    // 儲存每個分類的 cafe 清單
    func saveCafeDict(_ dict: [String: [CafeInfoObject]]) {
        do {
            let data = try JSONEncoder().encode(dict)
            try data.write(to: fileURL)
            print("✅ 已儲存多分類快取到本地：\(fileURL)")
        } catch {
            print("❌ 儲存快取失敗：\(error)")
        }
    }

    // 載入快取的分類 -> cafe 清單
    func loadCafeDict() -> [String: [CafeInfoObject]]? {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([String: [CafeInfoObject]].self, from: data)
            print("✅ 已從本地快取讀取多分類資料")
            return decoded
        } catch {
            print("⚠️ 無法讀取快取：\(error)")
            return nil
        }
    }

    // 檢查快取是否存在
    func hasCache() -> Bool {
        FileManager.default.fileExists(atPath: fileURL.path)
    }

    // 清除快取（可用於 debug）
    func clearCache() {
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("🗑 已清除快取")
        } catch {
            print("❌ 清除快取失敗：\(error)")
        }
    }
}
