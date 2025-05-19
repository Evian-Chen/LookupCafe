//
//  CategoryManager.swift
//  lookupCafe
//
//  Created by mac03 on 2025/4/28.
//

import Foundation
import FirebaseFirestore

class FirestoreManager {
    @Published var db: Firestore

    init() {
        self.db = Firestore.firestore()
    }
}

class CategoryManager: ObservableObject {
    @Published var categoryObjcList: [String: Categoryobjc]
    @Published var categories: [String]
    @Published var isLoaded = false

    let categoryFile = "categoryList"
    private var fsManager = FirestoreManager()
    private var locManager = LocationDataManager()

    init() {
        self.categoryObjcList = [:]
        self.categories = []
    }

    @MainActor
    func asyncInit() async {
        self.categories = readInCategories()
        
//        LocalCacheManager.shared.clearCache()  // 清除沙盒資料
        if let cached = LocalCacheManager.shared.loadCafeDict() {
            for (category, cafeList) in cached {
                let obj = Categoryobjc(categoryName: category, data: [])
                obj.cleanCafeData = cafeList
                self.categoryObjcList[category] = obj
            }
            self.isLoaded = true
            return
        }

        self.categoryObjcList = await loadCategoryData()
        self.isLoaded = true
    }

    private func loadCategoryData() async -> [String: Categoryobjc] {
        print("loading category data")
        var result: [String: Categoryobjc] = [:]
        print(self.categories)

        for category in self.categories {
            let categoryObjc = Categoryobjc(categoryName: category, data: [])

            do {
                let categoryData = try await fsManager.db.collection(category).getDocuments()
                print("load in data, fetch from: \(category)")

                for cityDoc in categoryData.documents {
                    let city = cityDoc.documentID
                    print("cur city: \(city)")
                    guard let districts = locManager.cityDistricts[city] else {
                        print("\(city) not exists in locManager.cityDistricts")
                        continue
                    }

                    for district in districts {
                        print("cur district: \(district)")
                        let districtRef = cityDoc.reference.collection(district)
                        let cafeDoc = try await districtRef.getDocuments()

                        for cafeData in cafeDoc.documents {
                            categoryObjc.data.append(cafeData.data())
                        }
                    }
                }
            } catch {
                print("error getting document: \(error)")
            }

            await MainActor.run {
                categoryObjc.makeCleanData()
            }
            result[category] = categoryObjc
        }

        // 快取全部分類資料
        var dict: [String: [CafeInfoObject]] = [:]
        for (key, obj) in result {
            dict[key] = obj.cleanCafeData
            print("🔍 key=\(key), count=\(obj.cleanCafeData.count)")
        }
        LocalCacheManager.shared.saveCafeDict(dict)

        return result
    }

    private func readInCategories() -> [String] {
        print("read in categories")
        print(categoryFile)
        if let file = Bundle.main.url(forResource: categoryFile, withExtension: "txt") {
            do {
                let data = try String(contentsOf: file, encoding: .utf8)
                let lines = data.split(separator: "\n")
                print(lines)
                return lines.map { String($0) }
            } catch {
                print("reading categoryFile error: \(error)")
            }
        }
        return ["no shit"]
    }
}

class Categoryobjc: ObservableObject {
    @Published var categoryName: String
    @Published var data: [[String: Any]]
    @Published var cleanCafeData: [CafeInfoObject]

    init(categoryName: String, data: [[String: Any]]) {
        self.categoryName = categoryName
        self.data = data
        self.cleanCafeData = []
    }

    func makeCleanData() {
        print("start to check data")

        var cafeInfoObjList: [CafeInfoObject] = []

        for cafe in self.data {
            let servicesDict = cafe["services"] as? [String: Bool] ?? [:]
            let servicesArray = [
                servicesDict["serves_beer"] ?? false,
                servicesDict["serves_breakfast"] ?? false,
                servicesDict["serves_brunch"] ?? false,
                servicesDict["serves_dinner"] ?? false,
                servicesDict["serves_lunch"] ?? false,
                servicesDict["serves_wine"] ?? false,
                servicesDict["takeout"] ?? false
            ]

            let cleanCafeInfoObjc = CafeInfoObject(
                shopName: cafe["name"] as? String ?? "未知店名",
                city: cafe["city"] as? String ?? "未知城市",
                district: cafe["district"] as? String ?? "未知區域",
                address: cafe["formatted_address"] as? String ?? "未知地址",
                phoneNumber: cafe["formatted_phone_number"] as? String ?? "未提供電話",
                rating: (cafe["rating"] as? NSNumber)?.intValue ?? 0,
                services: servicesArray,
                types: cafe["types"] as? [String] ?? [],
                weekdayText: cafe["weekday_text"] as? [String] ?? ["no business hours available"],
                reviews: nil,
                latitude: cafe["latitude"] as? Double ?? 0.0,
                longitude: cafe["longitude"] as? Double ?? 0.0
            )

            cafeInfoObjList.append(cleanCafeInfoObjc)
            print("obj: \(cleanCafeInfoObjc)")
        }

        DispatchQueue.main.async {
            self.cleanCafeData = cafeInfoObjList
        }
    }
}

