//
//  LocationDataManager.swift
//  lookupCafe
//
//  Created by mac03 on 2025/4/5.
//

import Foundation
import CoreLocation
import Foundation

/**
 此class產生一個可負責監聽cityDistricts的物件（json檔案若有更新的話，會連動所有相關UI）
 self.cityDistricts格式如下：
 {
   "台北市": ["中正區", "大安區"],
   "新北市": ["板橋區", "新莊區"]
 }
 
 在初始化的時候，先把data從資料庫load到本地，如果資料庫有更新，再去更新本地的資料
 -> 固定時間更新檢查是否有新的資料
 
 */
class LocationDataManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var userLocation: CLLocationCoordinate2D? = nil
    @Published var cityDistricts: [String: [String]] = [:]
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        loadCityDistrictData()
        
        print("📍 啟動 LocationDataManager")
        print("目前授權狀態：\(locationManager.authorizationStatus.rawValue)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            DispatchQueue.main.async {
                print("抓到位置：\(location.coordinate)")
                self.userLocation = location.coordinate
            }
        }
    }
    
    private func loadCityDistrictData() {
        guard let url = Bundle.main.url(forResource: "city_district", withExtension: "json") else {
            print("city_district.json not found")
            return
        }
        do {
            print("city_district json found")
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([String: [String]].self, from: data)
            self.cityDistricts = decoded
        } catch {
            print("error: \(error)")
        }
    }
}
