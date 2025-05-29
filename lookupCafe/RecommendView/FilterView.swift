import SwiftUI

struct FilterPickerView: View {
    var filterOptionObj: FilterOptions
    var optionsArr: [String]

    @Binding var selected: String

    var body: some View {
        Picker(selection: $selected) {
            ForEach(optionsArr, id: \.self) { opt in
                Text(opt)
            }
        } label: {
            Text(filterOptionObj.defaultStr)
                .font(.title3)
        }
    }
}


struct FilterView: View {
    // Enums.swift
    @Binding var curFilterQuery: FilterQuery
    @Binding var isPrestend: Bool
    
    @State private var reset = false
    @State private var apply = false
    @State private var newFilterQuery = FilterQuery()
    @State private var cityDistrictMap: [String: [String]] = [:]
    
    @State var tempKeyword: [String] = [""]
    
    // 用FilterOptions type抓出對應的FilterQuery裡面的值
    func binding(for option: FilterOptions) -> Binding<String> {
        switch option {
        case .cities:
            return $newFilterQuery.cities
        case .districts:
            return $newFilterQuery.districts
        case .sockets:
            return $newFilterQuery.sockets
        case .wifi:
            return $newFilterQuery.wifi
        case .stayTime:
            return $newFilterQuery.stayTime
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                
                // Picker 區塊
                List {
                    ForEach(FilterOptions.allCases) { option in
                        let options: [String] = {
                            switch option {
                            case .cities:
                                return ["全部"] + Array(cityDistrictMap.keys)
                            case .districts:
                                if let districts = cityDistrictMap[newFilterQuery.cities], newFilterQuery.cities != "全部" {
                                    return ["全部"] + districts
                                } else {
                                    return ["全部"]
                                }
                            default:
                                return option.optionsArr
                            }
                        }()

                        FilterPickerView(filterOptionObj: option, optionsArr: options, selected: binding(for: option))
                    }
                }
                
                // 按鈕區
                HStack(spacing: 16) {
                    Button {
                        // 重置邏輯
                        reset.toggle()
                        tempKeyword = curFilterQuery.keyword
                        newFilterQuery = FilterQuery()
                        newFilterQuery.keyword = tempKeyword
                    } label: {
                        Text("重置")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                    }
                    
                    Button {
                        // 套用邏輯
                        tempKeyword = curFilterQuery.keyword
                        curFilterQuery = newFilterQuery
                        curFilterQuery.keyword = tempKeyword
                        isPrestend.toggle()
                    } label: {
                        Text("套用")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal)
                .padding(.bottom, 40)
                
                Spacer()
            }
            .navigationTitle("條件篩選")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let url = Bundle.main.url(forResource: "city_district", withExtension: "json"),
                   let data = try? Data(contentsOf: url),
                   let json = try? JSONDecoder().decode([String: [String]].self, from: data) {
                    cityDistrictMap = json
                }
            }
            .onChange(of: newFilterQuery.cities) { newCity in
                // 如果地區不屬於新的城市，則重設為「全部」
                guard newCity != "全部",
                      let validDistricts = cityDistrictMap[newCity],
                      validDistricts.contains(newFilterQuery.districts) == false else {
                    return
                }

                newFilterQuery.districts = "全部"
            }

        }
    }
}
