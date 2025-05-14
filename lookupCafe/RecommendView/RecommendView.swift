//
//  RecommendView.swift
//  lookupCafe
//
//  Created by mac03 on 2025/4/9.
//

import SwiftUI
import SwiftUICore

struct RecommendView: View {
    @StateObject var categoryManager: CategoryManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24, pinnedViews: .sectionHeaders) {
                    RecommendationSectionView(category: .beerCafe, categoryManager: categoryManager)
                    RecommendationSectionView(category: .highRatings, categoryManager: categoryManager)
                }
                .padding(.vertical)
            }
            .navigationTitle("推薦咖啡廳")
        }
    }
}


