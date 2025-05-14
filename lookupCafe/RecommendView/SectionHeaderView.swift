//
//  SectionHeaderView.swift
//  lookupCafe
//
//  Created by mac03 on 2025/5/1.
//

import SwiftUI

// 定義每個header的外觀
struct SectionHeaderView: View {
    var title: String
    var category: RecommendationCategory
    
    var body: some View {
        NavigationLink(destination: HeaderDetailView(category: category)) {
            HStack {
                Text(title)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue)
            )
            .padding(.horizontal, 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
