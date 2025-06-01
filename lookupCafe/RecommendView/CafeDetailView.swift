//
//  CafeDetailView.swift
//  lookupCafe
//
//  Created by mac03 on 2025/5/1.
//

import SwiftUI
import GoogleMaps
import MapKit

struct CafeMapPreviewView: UIViewRepresentable {
    var address: String
    var shopName: String
    
    class Coordinator {
        var mapView: GMSMapView?
        
        func geocodeAddress(address: String, shopName: String) {
            CLGeocoder().geocodeAddressString(address) { placemarks, error in
                guard let placemark = placemarks?[0], error == nil else { return }
                
                // 更新該咖啡廳的座標
                DispatchQueue.main.async {
                    let camera = GMSCameraPosition.camera(
                        withTarget: placemark.location!.coordinate,
                        zoom: 15
                    )
                    self.mapView!.camera = camera
                    
                    let marker = GMSMarker()
                    marker.position = placemark.location!.coordinate
                    marker.title = shopName
                    marker.map = self.mapView
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context)-> GMSMapView {
        // default location
        let camera = GMSCameraPosition.camera(
            withLatitude: 25.034012,  // 台北101
            longitude: 121.564461,
            zoom: 15
        )
        let mapView = GMSMapView(frame: .zero, camera: camera)
        
        context.coordinator.mapView = mapView
        context.coordinator.geocodeAddress(address: address, shopName: shopName)
        return mapView
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        // 這裡暫時不需要寫
    }
}

extension Image {
    func iconModifier() -> some View {
        self
            .padding()
            .frame(width: 20, height: 20)
            .cornerRadius(5)
    }
}

// 每間咖啡廳的詳細資料（整個頁面）
struct CafeDetailView: View {
    // 所有資料都儲存在cafeinfoobject
    var cafeObj: CafeInfoObject
    
    @ObservedObject var userManager = UserDataManager.shared
    
    @ViewBuilder
    func serviceIcon() -> some View {
        VStack {
            if cafeObj.services[1] {
                HStack {
                    Image(systemName: "cup.and.saucer.fill")
                        .iconModifier()
                    Text("早餐")
                }
            }
            if cafeObj.services[2] {
                HStack {
                    Image(systemName: "mug.fill")
                        .iconModifier()
                    Text("早午餐")
                }
            }
            if cafeObj.services[4] {
                HStack {
                    Image(systemName: "fork.knife")
                        .iconModifier()
                    Text("午餐")
                }
            }
            if cafeObj.services[3] {
                HStack {
                    Image(systemName: "moon.haze.fill")
                        .iconModifier()
                    Text("晚餐")
                }
            }
            if cafeObj.services[3] || cafeObj.services[0] {
                HStack {
                    Image(systemName: "wineglass.fill")
                        .iconModifier()
                    Text("酒精")
                }
            }
            if cafeObj.services[6] {
                HStack {
                    Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                        .iconModifier()
                    Text("外帶")
                }
            }
        }
    }

    @ViewBuilder
    func reviewCard() -> some View {
        if let reviews = cafeObj.reviews {
            ForEach(reviews.indices, id: \.self) { index in
                let review = reviews[index]
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(review.reviewer_name).font(.title).bold()
                        Text(String(review.reviewer_rating)).font(.title)
                        Image(systemName: "star")
                        
                        Spacer()
                        
                        Text(review.review_time)
                    }
                    
                    Text(review.reviewer_text).font(.subheadline)
                }
                .padding()
                .background(.gray.opacity(0.1))
                .cornerRadius(12)
            }
        } else {
            Text("No reviews yet")
                .frame(width: .infinity)
                .padding(.horizontal, 20)
        }
        
    }
    
    // 有至少一個服務項目才會顯示，沒有就沒有
    @ViewBuilder
    func serviceCard() -> some View {
        if cafeObj.services.contains(true) {
            DisclosureGroup("服務項目") {
                serviceIcon()
            }
            .padding(8)
            .background(.white)
            .cornerRadius(12)
        }
    }
    
    // apple map 導航功能
    func openInAppleMaps(latitude: Double, longitude: Double, placeName: String) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = placeName
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    // 顯示店名和加入我的最愛
                    Text(cafeObj.shopName)
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal, 8)
                    
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(cafeObj.rating))
                                .bold()
                                .font(.title3)
                        }
                        Spacer()
                        // 登入過後才會有愛心圖案
                        if userManager.isSignIn() {
                            HStack {
                                Button {
                                    userManager.toggleFavorite(cafeObj: cafeObj)
                                } label: {
                                    Image(systemName: userManager.isFavorite(cafeId: cafeObj.id.uuidString) ? "heart.fill" : "heart")
                                        .foregroundColor(.red)
                                }
                                Text(userManager.isFavorite(cafeId: cafeObj.id.uuidString) ? "已經加入我的最愛！" : "加入我的最愛")
                            }
                            .padding(.trailing, 20)
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Label(cafeObj.address, systemImage: "mappin.and.ellipse")
                                .font(.subheadline)
                            Label(cafeObj.phoneNumber, systemImage: "phone.fill")
                                .font(.subheadline)
                        }
                        
                        Button {
                            if let lat = cafeObj.latitude, let lng = cafeObj.longitude {
                                openInAppleMaps(latitude: lat, longitude: lng, placeName: cafeObj.shopName)
                            }
                        } label: {
                            Image(systemName: "location.fill")
                            Text("用 Apple 地圖導航")
                        }
                        .padding(4)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
                .background(.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 3)
                
                HStack {
                    // 營業時間
                    DisclosureGroup("營業時間") {
                        ForEach(cafeObj.weekdayText, id: \.self) { weekday in
                            Text(weekday)
                        }
                    }
                    .padding(8)
                    .background(.white)
                    .cornerRadius(12)
                    
                    // 服務項目
                    serviceCard()
                }
                
                
                // 地圖預覽
                CafeMapPreviewView(address: cafeObj.address, shopName: cafeObj.shopName)
                    .frame(height: 300)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                
                // 評論
                VStack(alignment: .leading, spacing: 12) {
                    Text("評論")
                        .bold()
                        .font(.title2)
                    reviewCard()
                }
                .padding()
                .background(.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 3)
            }
            .padding(.horizontal, 20)
            .padding(.vertical)
            .background(Color(.systemGroupedBackground))
        }
    }
}
