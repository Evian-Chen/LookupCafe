//
//  RecommendationSectionView.swift
//  lookupCafe
//
//  Created by mac03 on 2025/5/1.
//

import SwiftUI
import SwiftUICore

struct RecommendView: View {
    @StateObject var categoryManager: CategoryManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24, pinnedViews: .sectionHeaders) {
                    RecommendationSectionView(category: .highRatings, categoryManager: categoryManager)
                    RecommendationSectionView(category: .beerCafe, categoryManager: categoryManager)
                    RecommendationSectionView(category: .brunchCafe, categoryManager: categoryManager)
                    RecommendationSectionView(category: .dinnerCafe, categoryManager: categoryManager)
                }
                .padding(.vertical)
            }
            .navigationTitle("推薦咖啡廳")
        }
    }
}

struct RecommendationSectionView: View {
    var category: RecommendationCategory
    @EnvironmentObject var locationManager: LocationDataManager
    @ObservedObject var categoryManager: CategoryManager
    
    @State var filteredCafes: [CafeInfoObject] = []
    @State var isLoading: Bool = true
    
    var body: some View {
        Section {
            if isLoading {
                ProgressView("is loading...")
            } else if filteredCafes.isEmpty {
                Text("找不到咖啡廳")
            } else {
                ForEach(filteredCafes.prefix(5)) { cafe in
                    CafeInfoCardView(cafeObj: cafe)
                }
            }
        } header: {
            SectionHeaderView(title: category.title, category: category)
        }
        .task(id: categoryManager.isLoaded) {
            if categoryManager.isLoaded {
                await loadFilteredData()
            }
        }
    }
    
    func loadFilteredData() async {
        // 先得到某個類別的所有東西
        guard let obj = categoryManager.categoryObjcList[category.englishCategoryName] else {
            print("can not find category: \(category.englishCategoryName)")
            return
        }
        guard let userLoc = locationManager.userLocation else { return }
        let cafes = await obj.getDefaultFilterData(location: userLoc)
        filteredCafes = cafes
        isLoading = false
        print("結束loadFilteredData")
    }
}

struct SectionHeaderView: View {
    var title: String
    var category: RecommendationCategory
    @EnvironmentObject var categoryManager: CategoryManager
    
    var body: some View {
        NavigationLink(destination: HeaderDetailView(category: category, cafes: categoryManager.categoryObjcList[category.englishCategoryName]?.cleanCafeData ?? [])) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("點擊查看更多細節")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal, 20)
        }
    }
}
