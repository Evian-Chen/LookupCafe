//
//  MapView.swift
//  lookupCafe
//
//  Created by mac03 on 2025/4/9.
//

import SwiftUI
import GoogleMaps

struct GooglePlaceResult: Codable {
    let results: [GooglePlace]
}

struct GooglePlace: Codable {
    let name: String
    let formatted_address: String
    let geometry: Geometry
    let place_id: String
    let rating: Double?
    let types: [String]
}

struct Geometry: Codable {
    let location: Location
    struct Location: Codable {
        let lat: Double
        let lng: Double
    }
}

func convertToCafe(place: GooglePlace, completion: @escaping (CafeInfoObject) -> Void) {
    let apiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleSearchApi") as? String
    let placeID = place.place_id
    let detailUrl = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&fields=name,rating,formatted_phone_number,reviews,opening_hours,website,photos&key=\(apiKey)")!

    URLSession.shared.dataTask(with: detailUrl) { data, _, error in
        guard let data = data, error == nil else {
            print("Request error:", error ?? "Unknown error")
            return
        }

        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let rawResult = jsonObject["result"] as? [String: Any] {

                let phoneNumber = rawResult["formatted_phone_number"] as? String ?? "未提供電話"

                var weekdayText: [String] = ["無營業時間資訊"]
                if let openingHours = rawResult["opening_hours"] as? [String: Any],
                   let weekdays = openingHours["weekday_text"] as? [String] {
                    weekdayText = weekdays
                }

                var reviews: [Review] = []
                if let reviewList = rawResult["reviews"] as? [[String: Any]] {
                    for review in reviewList {
                        let reviewerName = review["author_name"] as? String ?? "匿名"
                        let rating = review["rating"] as? Int ?? 0
                        let text = review["text"] as? String ?? ""
                        let timeDesc = review["relative_time_description"] as? String ?? ""
                        let r = Review(
                            review_time: timeDesc,
                            reviewer_name: reviewerName,
                            reviewer_rating: rating,
                            reviewer_text: text
                        )
                        reviews.append(r)
                    }
                }

                let cafe = CafeInfoObject(
                    shopName: place.name,
                    city: "未知城市",
                    district: "未知區域",
                    address: place.formatted_address,
                    phoneNumber: phoneNumber,
                    rating: Int(place.rating ?? 0),
                    services: [false, false, false],
                    types: place.types ?? [],
                    weekdayText: weekdayText,
                    reviews: reviews
                )

                DispatchQueue.main.async {
                    completion(cafe)
                }
            }
        } catch {
            print("JSON parsing failed:", error)
        }
    }.resume()
}

func geocodeAddress(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
    let apiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleSearchApi") as? String
    let query = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let urlStr = "https://maps.googleapis.com/maps/api/geocode/json?address=\(query)&key=\(apiKey)"
    guard let url = URL(string: urlStr) else {
        completion(nil)
        return
    }

    URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let geometry = results.first?["geometry"] as? [String: Any],
              let location = geometry["location"] as? [String: Double],
              let lat = location["lat"],
              let lng = location["lng"] else {
            completion(nil)
            return
        }
        completion(CLLocationCoordinate2D(latitude: lat, longitude: lng))
    }.resume()
}

// 針對地圖本身的異動
struct GMSMapsView: UIViewRepresentable {
    var cafes: [CafeInfoObject]
    @Binding var selectedCafe: CafeInfoObject?
    @Binding var isSheetPresented: Bool
    @Binding var centerCoordinate: CLLocationCoordinate2D?

    @EnvironmentObject var locationDataManager: LocationDataManager

    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: GMSMapsView
        var userMarker: GMSMarker?

        init(_ parent: GMSMapsView) {
            self.parent = parent
        }

        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            if let cafe = marker.userData as? CafeInfoObject {
                print("使用者點擊 \(cafe.shopName)")
                parent.selectedCafe = cafe
                parent.isSheetPresented = true
            }
            return true
        }

        /// 建立使用者 marker（僅建立一次）
        func addUserMarker(to mapView: GMSMapView, at coord: CLLocationCoordinate2D) {
            if userMarker == nil {
                let marker = GMSMarker(position: coord)
                marker.title = "📍 現在位置"
                marker.icon = GMSMarker.markerImage(with: .systemRed)
                marker.map = mapView
                self.userMarker = marker
            } else {
                userMarker?.position = coord
                userMarker?.map = mapView
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(
            withLatitude: locationDataManager.userLocation?.latitude ?? 24.0000,
            longitude: locationDataManager.userLocation?.longitude ?? 121.564461,
            zoom: 14
        )

        let mapView = GMSMapView(frame: .zero, camera: camera)
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        if let coord = centerCoordinate {
            let camera = GMSCameraPosition.camera(withTarget: coord, zoom: 15)
            mapView.animate(to: camera)

            // 永久顯示 user marker（不會被 clear 清除）
            context.coordinator.addUserMarker(to: mapView, at: coord)

            DispatchQueue.main.async {
                context.coordinator.userMarker?.title = "目前位置"
                centerCoordinate = nil
            }
        }

        mapView.clear()

        // 重新加回 user marker（因為 clear 會把全部清掉）
        if let userMarker = context.coordinator.userMarker {
            userMarker.map = mapView
        }

        for cafe in cafes {
            geocodeAddress(address: cafe.address) { coord in
                guard let coord = coord else { return }

                DispatchQueue.main.async {
                    let marker = GMSMarker()
                    marker.position = coord
                    marker.title = "☕️ \(cafe.shopName)"
                    marker.snippet = cafe.address
                    marker.userData = cafe
                    marker.icon = GMSMarker.markerImage(with: .brown)
                    marker.map = mapView
                }
            }
        }
    }
}


struct MapView: View {
    @EnvironmentObject var locationManager: LocationDataManager
    
    @State private var searchText = ""
    @State private var isEditing = false
    
    @State var searchResults: [CafeInfoObject] = []
    @State private var selectedCafe: CafeInfoObject? = nil
    @State private var isSheetPresented = false
    @State private var centerCoordinate: CLLocationCoordinate2D? = nil
    
    
    var body: some View {
        ZStack {
            //             地圖
            GMSMapsView(cafes: searchResults,
                        selectedCafe: $selectedCafe,
                        isSheetPresented: $isSheetPresented,
                        centerCoordinate: $centerCoordinate)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 美化後的選擇列
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Search...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .overlay(
                            HStack {
                                Spacer()
                                
                                if isEditing {
                                    Button {
                                        searchText = ""
                                    } label: {
                                        Image(systemName: "multiply.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 8)
                                    }
                                }
                                
                                Button("搜尋") {
                                    print(searchText)
                                    isEditing = false
                                    searchText = ""
                                    
                                    // 查詢
                                    searchPlaces(keyword: searchText) { cafeList in
                                        self.searchResults = cafeList
                                    }
                                    
                                    // Dismiss the keyboard
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                                .padding(.horizontal)
                            }
                        )
                        .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 2)
                        .padding(.horizontal)
                        .onTapGesture {
                            isEditing = true
                        }
                    
                    HStack {
                        Spacer()
                        Button {
                            backToUserLocation()
                        } label: {
                            Image(systemName: "mappin.and.ellipse.circle")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .background(.white)
                                .cornerRadius(12)
                                .padding(.trailing, 20)
                        }
                    }
                    
                    Spacer()
                } // VStack
            }
            .sheet(isPresented: $isSheetPresented) {
                if let cafeObj = selectedCafe {
                    CafeDetailView(cafeObj: cafeObj)
                }
            }
            .onAppear {
                if let coordinates = locationManager.userLocation {
                    let query = "\(coordinates.longitude), \(coordinates.latitude)"
                    searchPlaces(keyword: query) { cafeList in
                        self.searchResults = cafeList
                    }
                    
                    print("query: \(query)")
                    
                    backToUserLocation()
                } else {
                    print("還沒定位")
                }
            }
        }
    }
    
    func searchPlaces(keyword: String, completion: @escaping ([CafeInfoObject]) -> Void) {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleSearchApi") as? String
        
        print("test google search api: \(apiKey)")
        
        let query = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlStr = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(query)&key=\(apiKey)"
        guard let url = URL(string: urlStr) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }

            do {
                let result = try JSONDecoder().decode(GooglePlaceResult.self, from: data)
                let places = result.results

                var cafeList: [CafeInfoObject] = []
                let group = DispatchGroup()

                for place in places {
                    group.enter()
                    convertToCafe(place: place) { cafe in
                        cafeList.append(cafe)
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    completion(cafeList)
                }

            } catch {
                print("Parsing error:", error)
            }

        }.resume()
    }
    
    func backToUserLocation() {
        print("back to user location")
        if let coord = locationManager.userLocation {
            centerCoordinate = coord
        }
        // 將地圖啦回原本的位置
    }

}
