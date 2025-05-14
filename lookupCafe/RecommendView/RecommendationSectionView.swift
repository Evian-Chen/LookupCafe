//
//  RecommendationSectionView.swift
//  lookupCafe
//
//  Created by mac03 on 2025/5/1.
//

import SwiftUI

struct RecommendationSectionView: View {
    var category: RecommendationCategory
    @ObservedObject var categoryManager: CategoryManager

    var body: some View {
        Section {
            let cafes = categoryManager.categoryObjcList[category.englishCategoryName]?.cleanCafeData ?? []

            if cafes.isEmpty {
                Text("載入中...")
            } else {
                ForEach(cafes.prefix(5)) { cafe in
                    CafeInfoCardView(cafeObj: cafe)
                }
            }
        } header: {
            SectionHeaderView(title: category.title, category: category)
        }
    }
}

