//
//  CategoryManager.swift
//  lookupCafe
//
//  Created by mac03 on 2025/4/28.
//

import Foundation
import FirebaseFirestore
import CoreLocation

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

        // 嘗試載入每個分類的個別快取
        let cached = LocalCacheManager.shared.loadAll(self.categories)
        if !cached.isEmpty {
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
    
    func withTimeout<T>(
        seconds: TimeInterval,
        task: @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await task()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }

            guard let result = try await group.next() else {
                throw TimeoutError()
            }

            group.cancelAll()
            return result
        }
    }

    struct TimeoutError: Error {}

    private func loadCategoryData() async -> [String: Categoryobjc] {
        print("loading category data")
        var result: [String: Categoryobjc] = [:]
        print(self.categories)

        for category in self.categories {
            let categoryObjc = Categoryobjc(categoryName: category, data: [])

            do {
                let categoryData = try await fsManager.db.collection(category).getDocuments(source: .server)
                print("load in data, fetch from: \(category)")

                for cityDoc in categoryData.documents {
                    await Task.yield()

                    let city = cityDoc.documentID
                    print("cur city: \(city)")
                    guard let districts = locManager.cityDistricts[city] else {
                        continue
                    }

                    for district in districts {
                        print("cur district: \(district)")
                        let districtRef = cityDoc.reference.collection(district)
                        print("waiting ref ", districtRef)
                        
                        await Task.yield()

                        do {
                            let cafeDoc = try await withTimeout(seconds: 10) {
                                try await districtRef.getDocuments(source: .server)
                            }

                            print("成功取得 \(cafeDoc.count) 筆資料 from \(district)")

                            for cafeData in cafeDoc.documents {
                                categoryObjc.data.append(cafeData.data())
                            }

                        } catch {
                            print("district \(district) 發生錯誤或超時：\(error.localizedDescription)")
                            continue
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

        // 使用新快取邏輯：逐一儲存分類
        var dict: [String: [CafeInfoObject]] = [:]
        for (key, obj) in result {
            dict[key] = obj.cleanCafeData
            print("🔍 key=\(key), count=\(obj.cleanCafeData.count)")
        }
        LocalCacheManager.shared.saveAll(categories: dict)

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
            
            let reviewDicts = cafe["reviews"] as? [[String: Any]]
            let reviews: [Review]? = reviewDicts?.compactMap { dict in
                guard
                    let time = dict["review_time"] as? String,
                    let name = dict["reviewer_name"] as? String,
                    let text = dict["review_text"] as? String
                else {
                    return nil
                }

                // 嘗試強轉 Int，fallback 使用 NSNumber
                let rating: Int
                if let intRating = dict["reviewer_rating"] as? Int {
                    rating = intRating
                } else if let numRating = dict["reviewer_rating"] as? NSNumber {
                    rating = numRating.intValue
                } else {
                    rating = 0 // 預設值，或 return nil
                }

                return Review(
                    review_time: time,
                    reviewer_name: name,
                    reviewer_rating: rating,
                    reviewer_text: text
                )
            }

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
                reviews: reviews ?? [],
                latitude: cafe["latitude"] as? Double ?? 0.0,
                longitude: cafe["longitude"] as? Double ?? 0.0
            )

            cafeInfoObjList.append(cleanCafeInfoObjc)
        }

        DispatchQueue.main.async {
            self.cleanCafeData = cafeInfoObjList
        }
    }
    
    func getFilteredData(location: CLLocationCoordinate2D, filter: FilterQuery, defaultCafes: [CafeInfoObject]) -> [CafeInfoObject] {
        print("cur filter: \(filter)")
        print("default cafes count: \(defaultCafes.count)")
        
        // 如果條件完全沒設定，就直接回傳預設列表
        let hasAnyFilter =
            !(filter.keyword.isEmpty) ||
            filter.cities != "全部" ||
            filter.districts != "全部" ||
            filter.sockets != "全部" ||
            filter.wifi != "全部" ||
            filter.stayTime != "全部"
        
        print("hasAnyFilter: \(hasAnyFilter)")

        guard hasAnyFilter else {
            return defaultCafes
        }

        // OR 策略：只要有一個條件符合，就納入
        return defaultCafes.filter { cafe in
            var match = false

            // 關鍵字（名稱 / 地址）
            if !filter.keyword.isEmpty && !(filter.keyword.count == 1 && filter.keyword[0].isEmpty) {
                let lowerKeywords = filter.keyword.map { $0.lowercased() }
                let name = cafe.shopName.lowercased()
                let address = cafe.address.lowercased()
                if lowerKeywords.contains(where: { name.contains($0) || address.contains($0) }) {
                    match = true
                }
            }

            // 城市
            if filter.cities != "全部", cafe.city == filter.cities {
                match = true
            }

            // 區域
            if filter.districts != "全部", cafe.district == filter.districts {
                match = true
            }

            // 插座
            if filter.sockets == "有插座", cafe.services.indices.contains(6), cafe.services[6] {
                match = true
            }

            // Wifi
            if filter.wifi == "有 Wi-Fi", cafe.types.contains("wifi") {
                match = true
            }

            // 可久坐
            if filter.stayTime == "可久坐", cafe.types.contains("long_stay") {
                match = true
            }

            return match
        }
    }

    
    func getDefaultFilterData(location: CLLocationCoordinate2D) async -> [CafeInfoObject] {
        print("at getDefaultFilterData")
        
        guard let locationArray = await getCityDist(location: location),
              locationArray.count == 2 else {
            print("無法取得地理位置")
            return []
        }

        let city = locationArray[0]
        let district = locationArray[1]

        guard !city.isEmpty, !district.isEmpty else {
            print("取得的地理位置為空")
            return []
        }

        let all = self.cleanCafeData
        let matched = all.filter { $0.city == city && $0.district == district }

        print("Filtered \(matched.count) cafes for \(city)-\(district)")
        return matched
    }
    
    func getCityDist(location: CLLocationCoordinate2D) async -> [String]? {
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)

        return await withCheckedContinuation { continuation in
            geocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
                if let error = error {
                    print("Reverse geocode failed: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                    return
                }

                guard let placemark = placemarks?.first else {
                    continuation.resume(returning: nil)
                    return
                }

                let city = placemark.administrativeArea ?? ""
                let district = placemark.locality ?? placemark.subAdministrativeArea ?? ""
                continuation.resume(returning: [city, district])
            }
        }
    }
}
