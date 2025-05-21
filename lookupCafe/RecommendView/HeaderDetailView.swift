//
//  HeaderDetailView.swift
//  lookupCafe
//
//  Created by mac03 on 2025/5/1.
//

import SwiftUI

// 點進去之後出現該分類的每一間咖啡廳
struct HeaderDetailView: View {
    var category: RecommendationCategory
    var cafes: [CafeInfoObject]
    @State private var filteredCafes: [CafeInfoObject] = []
    
    @EnvironmentObject var locationManager: LocationDataManager
    
    @State private var showingSheetFilter = false
    @State var curFilterQuery: FilterQuery = FilterQuery()
    @State private var searchText = ""
    @State private var showingDeleteAlert = false
    @State private var labelToDel: String? = ""
    @State private var keywordToDel: String? = nil
    @FocusState private var isFocued: Bool
    
    @EnvironmentObject var categoryManager: CategoryManager
    
    let columns = [
        GridItem(.adaptive(minimum: 80), spacing: 10)
    ]
    
    func updateFiltered() {
        guard let location = locationManager.userLocation,
              let categoryObj = categoryManager.categoryObjcList[category.englishCategoryName] else {
            return
        }

        filteredCafes = categoryObj.getFilteredData(
            location: location,
            filter: curFilterQuery,
            defaultCafes: cafes
        )
    }

    
    var body: some View {
        NavigationStack {
            
            // 搜尋欄
            HStack {
                TextField("輸入關鍵字", text: $searchText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .focused($isFocued)
                
                if isFocued {
                    Button("取消") {
                        isFocued = false
                        searchText = ""
                    }
                    .foregroundColor(.red)
                    
                    // 新增這個關鍵字，並增加到畫面上
                    Button("新增") {
                        if !searchText.isEmpty {
                            curFilterQuery.keyword.append(searchText)
                            searchText = ""
                            isFocued = false
                        }
                    }
                } // if isEditing
            } // hstack
            .padding(.horizontal)
            
            // 印出篩選的關鍵字
            LazyVGrid(columns: columns, alignment: .leading) {
                ForEach(Array(Mirror(reflecting: curFilterQuery).children.enumerated()), id: \.offset) { index, child in
                    if let label = child.label {
                        if ("\(child.value)" != "全部" && label != "keyword") {
                            Button {
                                showingDeleteAlert = true
                                labelToDel = label
                            } label: {
                                Text("\(child.value)")
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(7)
                                    .background(.blue)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                
                ForEach(curFilterQuery.keyword.filter { !$0.isEmpty }, id: \.self) { word in
                    Button {
                        showingDeleteAlert = true
                        labelToDel = "keyword"
                        keywordToDel = word
                    } label: {
                        Text("\(word)")
                            .bold()
                            .foregroundColor(.white)
                            .padding(7)
                            .background(.blue)
                            .cornerRadius(10)
                    }
                }
            } // lazyVgrid
            .padding(20)
            .alert("確定要刪除這個關鍵字嗎？", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("刪除", role: .destructive) {
                    if labelToDel == "keyword" {
                        if let index = curFilterQuery.keyword.firstIndex(of: keywordToDel ?? "") {
                            curFilterQuery.keyword.remove(at: index)
                        }
                    } else {
                        switch labelToDel {
                        case "cities":
                            curFilterQuery.cities = "全部"
                        case "districts":
                            curFilterQuery.districts = "全部"
                        case "sockets":
                            curFilterQuery.sockets = "全部"
                        case "wifi":
                            curFilterQuery.wifi = "全部"
                        case "stayTime":
                            curFilterQuery.stayTime = "全部"
                        default:
                            break
                        }
                    }
                }
            }
            
            ScrollView {
                VStack(spacing: 16) {
                    if cafes.isEmpty {
                        Text("沒有該分類資料")
                    } else {
                        // 在使用者使用篩選之前，先以目前所在縣市進行顯示，如果篩選的內容不為空，就要顯示篩選過後的咖啡廳（使用filterQuery）
                        if filteredCafes.isEmpty {
                            Text("找不到符合條件的咖啡廳")
                        } else {
                            ForEach(filteredCafes.prefix(10)) { cafe in
                                CafeInfoCardView(cafeObj: cafe)
                            }
                        }

                    }
                }
                .padding(.top)
            }
            .onAppear {
                print("🪵 categoryName: \(category.rawValue)")
            }
            .navigationTitle("這裡是 \(category.title)")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSheetFilter = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            .sheet(isPresented: $showingSheetFilter) {
                FilterView(curFilterQuery: $curFilterQuery, isPrestend: $showingSheetFilter)
            }
            .onChange(of: curFilterQuery) { _ in
                updateFiltered()
            }
            .onAppear {
                updateFiltered()
            }
        }
    }
    
    
}
