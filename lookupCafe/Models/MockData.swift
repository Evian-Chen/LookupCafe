//
//  MockData.swift
//  lookupCafe
//
//  Created by mac03 on 2025/4/21.
//
// 包含 sampleCafes, SamplePetCafes
// MockData.swift

let sampleCafes: [CafeInfoObject] = [
    CafeInfoObject(
        shopName: "喵喵森林咖啡",
        city: "台北市",
        district: "中山區",
        address: "中山北路二段33號",
        phoneNumber: "02-1234-5678",
        rating: 5,
        services: [true, true, false],
        types: ["pet", "relax", "instagrammable"],
        weekdayText: ["週一至週五: 10:00–20:00", "週末: 09:00–21:00"],
        reviews: [
             Review(review_time: "2025-04-01", reviewer_name: "小美", reviewer_rating: 5, reviewer_text: "非常適合帶寵物的咖啡廳，氣氛很好。")
        ]
    ),
    CafeInfoObject(
        shopName: "森林工作咖啡廳",
        city: "台北市",
        district: "大安區",
        address: "和平東路一段77號",
        phoneNumber: "02-9876-5432",
        rating: 4,
        services: [true, false, true],
        types: ["work", "wifi", "quiet"],
        weekdayText: ["每日: 08:00–22:00"],
        reviews: [
             Review(review_time: "2025-04-02", reviewer_name: "小志", reviewer_rating: 4, reviewer_text: "安靜適合工作，有免費wifi。")
        ]
    ),
    CafeInfoObject(
        shopName: "咖啡喵星球",
        city: "新北市",
        district: "板橋區",
        address: "文化路二段188號",
        phoneNumber: "02-3344-5566",
        rating: 3,
        services: [true, true, true],
        types: ["pet", "work", "spacious"],
        weekdayText: ["週一至週日: 10:00–19:00"],
        reviews: [
             Review(review_time: "2025-04-03", reviewer_name: "阿宏", reviewer_rating: 3, reviewer_text: "空間大但客人稍多，適合聊天。")
        ]
    ),
    CafeInfoObject(
        shopName: "悠然時光咖啡",
        city: "台中市",
        district: "西區",
        address: "公益路100號",
        phoneNumber: "04-2255-3344",
        rating: 4,
        services: [true, false, false],
        types: ["relax", "brunch"],
        weekdayText: ["平日: 09:00–18:00", "假日: 10:00–20:00"],
        reviews: [
             Review(review_time: "2025-04-04", reviewer_name: "子芸", reviewer_rating: 4, reviewer_text: "週末常客滿，建議平日來訪。")
        ]
    ),
    CafeInfoObject(
        shopName: "光合作用書咖啡",
        city: "台南市",
        district: "東區",
        address: "東門路一段88號",
        phoneNumber: "06-2255-6677",
        rating: 5,
        services: [true, true, true],
        types: ["work", "study", "quiet"],
        weekdayText: ["每日: 08:30–21:30"],
        reviews: [
             Review(review_time: "2025-04-05", reviewer_name: "Emily", reviewer_rating: 5, reviewer_text: "適合閱讀與長時間靜坐。")
        ]
    ),
    CafeInfoObject(
        shopName: "Daily Beans",
        city: "台北市",
        district: "信義區",
        address: "松山路10巷5號",
        phoneNumber: "02-5566-7788",
        rating: 4,
        services: [true, false, true],
        types: ["hipster", "instagrammable", "brunch"],
        weekdayText: ["週一至週五: 09:00–17:00", "週末公休"],
        reviews: [
             Review(review_time: "2025-04-06", reviewer_name: "Jack", reviewer_rating: 4, reviewer_text: "非常適合打卡拍照的早午餐店。")
        ]
    ),
    CafeInfoObject(
        shopName: "Chill Corner Cafe",
        city: "新竹市",
        district: "北區",
        address: "北門街60號",
        phoneNumber: "03-3456-7890",
        rating: 3,
        services: [false, true, false],
        types: ["pet", "casual", "local"],
        weekdayText: ["每日: 10:00–18:00"],
        reviews: [
             Review(review_time: "2025-04-07", reviewer_name: "志強", reviewer_rating: 3, reviewer_text: "本地人常去的小店，寵物友善。")
        ]
    )
]

let SamplePetCafes: [CafeInfoObject] = [
    CafeInfoObject(
        shopName: "毛孩樂園咖啡",
        city: "新北市",
        district: "新店區",
        address: "寶橋路123號",
        phoneNumber: "02-2912-3456",
        rating: 5,
        services: [true, true, false],
        types: ["pet", "garden", "family-friendly"],
        weekdayText: ["每日: 10:00–20:00"],
        reviews: [
             Review(review_time: "2025-04-08", reviewer_name: "安娜", reviewer_rating: 5, reviewer_text: "非常適合帶毛孩放鬆玩耍。")
        ]
    ),
    CafeInfoObject(
        shopName: "狗狗日記咖啡廳",
        city: "台北市",
        district: "士林區",
        address: "天母東路66號",
        phoneNumber: "02-2831-9876",
        rating: 4,
        services: [true, false, true],
        types: ["pet", "brunch", "cozy"],
        weekdayText: ["週一至週五: 09:00–18:00", "週末: 10:00–19:00"],
        reviews: [
             Review(review_time: "2025-04-09", reviewer_name: "小任", reviewer_rating: 4, reviewer_text: "餐點好吃但座位稍少。")
        ]
    ),
    CafeInfoObject(
        shopName: "毛絨森林",
        city: "桃園市",
        district: "中壢區",
        address: "中央西路二段18號",
        phoneNumber: "03-4256-7788",
        rating: 4,
        services: [true, true, true],
        types: ["pet", "relax", "spacious"],
        weekdayText: ["每日: 11:00–20:00"],
        reviews: [
             Review(review_time: "2025-04-10", reviewer_name: "阿良", reviewer_rating: 4, reviewer_text: "空間寬敞，適合團體聚會。")
        ]
    ),
    CafeInfoObject(
        shopName: "貓與咖啡",
        city: "台中市",
        district: "北區",
        address: "梅川西路三段99號",
        phoneNumber: "04-2233-1122",
        rating: 3,
        services: [true, false, false],
        types: ["pet", "instagrammable", "minimal"],
        weekdayText: ["平日: 10:00–18:00", "假日: 10:00–20:00"],
        reviews: [
             Review(review_time: "2025-04-11", reviewer_name: "小芸", reviewer_rating: 3, reviewer_text: "裝潢極簡風，貓咪可愛。")
        ]
    ),
    CafeInfoObject(
        shopName: "萌寵咖啡屋",
        city: "高雄市",
        district: "左營區",
        address: "自由三路88號",
        phoneNumber: "07-312-5566",
        rating: 5,
        services: [true, true, true],
        types: ["pet", "child-friendly", "brunch"],
        weekdayText: ["週一至週五: 10:00–17:00", "週末: 09:00–18:00"],
        reviews: [
             Review(review_time: "2025-04-12", reviewer_name: "阿德", reviewer_rating: 5, reviewer_text: "親子寵物友善空間，氛圍溫馨。")
        ]
    ),
    CafeInfoObject(
        shopName: "動物派對咖啡",
        city: "台南市",
        district: "中西區",
        address: "海安路二段11號",
        phoneNumber: "06-223-3344",
        rating: 4,
        services: [false, true, true],
        types: ["pet", "event", "themed"],
        weekdayText: ["每日: 12:00–22:00"],
        reviews: [
             Review(review_time: "2025-04-13", reviewer_name: "May", reviewer_rating: 4, reviewer_text: "主題風格強烈，活動豐富。")
        ]
    ),
    CafeInfoObject(
        shopName: "尾巴搖搖咖啡館",
        city: "新竹市",
        district: "東區",
        address: "光復路一段78號",
        phoneNumber: "03-567-1234",
        rating: 3,
        services: [true, false, true],
        types: ["pet", "casual", "light-meal"],
        weekdayText: ["週一至週日: 09:30–19:00"],
        reviews: [
             Review(review_time: "2025-04-14", reviewer_name: "Nina", reviewer_rating: 3, reviewer_text: "輕食選擇豐富，適合慢活午後。")
        ]
    )
]

