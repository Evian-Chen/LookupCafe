//
//  MyFovoriteView.swift
//  lookupCafe
//
//  Created by mac03 on 2025/5/13.
//

import SwiftUI
import FirebaseAuth


struct MyFovoriteView: View {
    @ObservedObject var user = UserDataManager.shared
    
    var body: some View {
        if user.favoritesCafes.count != 0 {
            VStack {
                ForEach(user.favoritesCafes) { cafe in
                    CafeInfoCardView(cafeObj: cafe)
                }
            }
        } else {
            Text("探索咖啡廳加入我的最愛！")
        }
        
    }
}
