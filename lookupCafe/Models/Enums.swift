//
//  Enums.swift
//  lookupCafe
//
//  Created by mac03 on 2025/4/20.
//
import SwiftUI

// MARK: - TabItemObj
/// 定義底部 TabView 的圖示與文字
enum TabItemObj: String {
    case recommend = "sparkle.magnifyingglass"
    case map = "map.fill"
    case profile = "person.crop.circle"
    
    /// 對應的 SF Symbol 圖示
    var image: Image {
        Image(systemName: self.rawValue)
    }
    
    /// Tab 的顯示文字
    var text: Text {
        switch self {
        case .recommend: return Text("探索")
        case .map: return Text("首頁")
        case .profile: return Text("我的帳號")
        }
    }
}

// MARK: - FilterOptions
/// 定義篩選項目類型及對應選項內容
enum FilterOptions: String, CaseIterable, Identifiable {
    var id: Self { self }
    
    case cities = "城市"
    case districts = "地區"
    case sockets = "插座"
    case wifi = "網路"
    case stayTime = "用餐時間"
    
    /// 該篩選類別對應的選項陣列
    var optionsArr: [String] {
        switch self {
        case .cities:
            return ["全部", "台北市", "新北市", "嘉義市"]
        case .districts:
            return ["全部", "新店區", "大安區", "中山區"]
        case .sockets:
            return ["全部", "沒有插座", "少許插座", "很多插座"]
        case .wifi:
            return ["全部", "有wifi", "沒有wifi"]
        case .stayTime:
            return ["全部", "用餐時間有限制", "用餐時間無限制"]
        }
    }
    
    /// 用於顯示的標題文字（中文）
    var defaultStr: String {
        self.rawValue
    }
}

// MARK: - RecommendationCategory
/// 探索頁面中的推薦分類類型
enum RecommendationCategory: String {
    case highRatings = "highRatings"
    case beerCafe = "serves_beer"
    case brunchCafe = "serves_brunch"
    case dinnerCafe = "serves_dinner"
    
    /// 顯示在 UI 上的中文標題
    var title: String {
        switch self {
        case .beerCafe:
            return "有酒的咖啡廳"
        case .highRatings:
            return "熱門咖啡廳"
        case .brunchCafe:
            return "早午餐咖啡廳"
        case .dinnerCafe:
            return "有晚餐的咖啡廳"
        }
    }
    
    var englishCategoryName: String {
        return self.rawValue
    }
}

// MARK: - ProfileData
//enum ProfileData: String, CaseIterable {
//    case myFavorite = "我的最愛"
//    case settings = "設定"
//    
//    @ViewBuilder
//    var ButtonView: some View {
//        switch self {
//        case .myFavorite:
//            NavigationLink {
//                MyFovoriteView()
//            } label: {
//                Text(self.rawValue)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .cornerRadius(10)
//                    .padding(.horizontal, 50)
//            }
//        case .settings:
//            NavigationLink {
//                SettingsView(authViewModel: AuthViewModel())
//            } label: {
//                Text(self.rawValue)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .cornerRadius(10)
//                    .padding(.horizontal, 50)
//            }
//        }
//    }
//}
