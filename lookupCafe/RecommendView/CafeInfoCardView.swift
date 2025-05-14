//
//  CafeInfoCardView.swift
//  lookupCafe
//
//  Created by mac03 on 2025/5/1.
//

import SwiftUI

// struct CafeInfoView
struct CafeInfoCardView: View {
    var cafeObj: CafeInfoObject
    
    var body: some View {
        NavigationLink {
            CafeDetailView(cafeObj: cafeObj)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(cafeObj.shopName)
                        .font(.title3)
                        .bold()
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("\(cafeObj.city) \(cafeObj.district)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text(cafeObj.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 2) {
                    ForEach(0 ..< cafeObj.rating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.footnote)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .padding(.horizontal, 20)
        }
    }
}
