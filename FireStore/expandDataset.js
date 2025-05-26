import { collection, doc, getDoc, setDoc } from "firebase/firestore";
import { db } from "./init_firestore.js"
import axios from "axios";
import { CITIES, DISTRICTS } from "./taiwanCityDistricts.js"
import dotenv from 'dotenv';

dotenv.config();
const GOOGLEAPIKEY = process.env.GOOGLE_MAP_API_KEY;
const CATEGORIES = ["highRatings", "serves_beer", "serves_brunch", "serves_dinner", "takeout"];

async function expandDataset() {
  console.log("KEY:", GOOGLEAPIKEY); 
  for (const city of CITIES) {
    if (city === "台北市") { city = "臺北市"; };

    for (const district of DISTRICTS[city]) {
      console.log(`searching ${city}, ${district}`);
      const cafes = await getNearByCafes(city, district);
      await categorize(city, district, cafes);

      console.log(`finish ${city}, ${district}`);
    }

    console.log(`finish ${city}`);
  }
}

async function getNearByCafes(city, district) {
  // 1. 把縣市切成小方塊
  const url = `https://maps.googleapis.com/maps/api/geocode/json?address=${city}${district}&language=zh-TW&key=${GOOGLEAPIKEY}`;
  const result = await axios.get(url);
  const data = result.data;

  if (data.status !== 'OK') {
    throw new Error (`error: status: ${data.status}`);
  }

  const res = data.results[0]; 
  const sw = res.geometry.viewport.southwest;
  const ne = res.geometry.viewport.northeast;

  const grid = generateGridPoints(sw, ne, 1000);
  console.log(`generate ${grid.length} grid point`);

  // 2. 搜尋每個小方塊
  const allCafes = [];
  const seen = new Set();
  for (const point of grid) {
    const cafeUrl = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${point.lat},${point.lng}&radius=1000&keyword=咖啡&language=zh-TW&key=${GOOGLEAPIKEY}`;
    console.log(`📍 Fetching ${city} ${district} cafes at:`, point.lat, point.lng);

    try {
      const cafeRes = await axios.get(cafeUrl);
      
      const cafeData = cafeRes.data;

      if (cafeData.status !== "OK" || !Array.isArray(cafeData.results)) {
        console.error(`❌ Google API error at (${point.lat}, ${point.lng}): ${cafeData.status}`);
        continue; // 繼續下一個 point，不中斷整體流程
      }

      const cafes = cafeData.results;
      // console.log("cafes: ", cafes);

      for (const cafe of cafes) {
        if (!seen.has(cafe.place_id)) {
          seen.add(cafe.place_id);
          allCafes.push(cafe);
        } 
      }
    } catch (e) {
      console.error("Failed to fetch detail:", e.message);
      return;
    }
  }

  // 3. 回傳透過小方塊找到的每間咖啡廳
  console.log("found ", allCafes.length, " cafes in ", city, district);
  return allCafes;
}

/**
 * 依據經緯度邊界產生格子狀查詢點（每個為中心點）
 * @param {Object} sw - 南西角 { lat, lng }
 * @param {Object} ne - 東北角 { lat, lng }
 * @param {Number} stepMeters - 每格距離，單位：公尺（預設 1000m）
 * @returns {Array<Object>} - 格子的中心點 [{ lat, lng }, ...]
 */
function generateGridPoints(sw, ne, stepMeters = 1000) {
  const points = [];

  const metersToLat = (meters) => meters / 111_000;
  const metersToLng = (meters, latitude) =>
    meters / (111_000 * Math.cos((latitude * Math.PI) / 180));

  const midLat = (sw.lat + ne.lat) / 2;
  const deltaLat = metersToLat(stepMeters);
  const deltaLng = metersToLng(stepMeters, midLat);

  for (let lat = sw.lat; lat <= ne.lat; lat += deltaLat) {
    for (let lng = sw.lng; lng <= ne.lng; lng += deltaLng) {
      points.push({ lat: Number(lat.toFixed(6)), lng: Number(lng.toFixed(6)) });
    }
  }

  return points;
}

// isQualifiedForCategory
async function categorize(city, district, cafes) {
  for (const cafe of cafes) {
    
    for (const category of CATEGORIES) {
      const cafeRef = doc(
        collection(db, category, city, district),
        `${cafe.name.replaceAll("/", "_")}_${cafe.place_id}`
      );
      
      const document = await getDoc(cafeRef);
      if (document.exists()) {
        continue;
      }

      // 該咖啡廳不存在資料庫，使用details搜尋，並加入資料庫
      await addToDataset(city, district, cafe, category, cafeRef);
    }
  }

  console.log("finish writing ", city, district);
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function addToDataset(city, district, cafe, category, cafeRef) {
  const detailUrl = `https://maps.googleapis.com/maps/api/place/details/json?place_id=${cafe.place_id}&language=zh-TW&key=${GOOGLEAPIKEY}`;

  try {
    const res = await axios.get(detailUrl);
    const data = res.data.result;

    // 決定該分類是否符合條件
    const categoryConditions = {
      highRatings: () => cafe.rating >= 4.3,
      serves_beer: () => data.serves_beer,
      serves_brunch: () => data.serves_brunch,
      serves_dinner: () => data.serves_dinner,
      takeout: () => data.takeout
    };

    const shouldAdd = categoryConditions[category]?.();
    if (!shouldAdd) {
      return;
    }

    const cafeData = buildCafeData(city, district, data);
    await setDoc(cafeRef, cafeData);
    console.log(`Written ${cafeData.name} to ${category}`);
  } catch (e) {
    console.error("Failed to fetch detail or write to Firestore:", e.message);
  }
}

function buildCafeData(city, district, data) {
  const cafeData = {
    city: city,
    district: district,
    formatted_address: data.formatted_address,
    formatted_phone_number: data.formatted_phone_number ?? "",
    name: data.name,
    rating: Math.round(data.rating ?? 0),
    price_level: data.price_level ?? null,
    services: {
      serves_beer: data.serves_beer ?? false,
      serves_breakfast: data.serves_breakfast ?? false,
      serves_brunch: data.serves_brunch ?? false,
      serves_dinner: data.serves_dinner ?? false,
      serves_lunch: data.serves_lunch ?? false,
      serves_wine: data.serves_wine ?? false,
      takeout: data.takeout ?? false
    },
    types: data.types ?? [],
    user_rating_total: data.user_ratings_total ?? 0,
    vicinity: data.vicinity ?? "",
    place_id: data.place_id,
    weekday_text: data.opening_hours?.weekday_text ?? ["not provided"],
    reviews: (data.reviews ?? []).map((r) => ({
      reviewer_name: r.author_name,
      reviewer_rating: r.rating,
      review_text: r.text,
      review_time: r.relative_time_description
    }))
  };  

  return cafeData;
}


async function main() {
  await expandDataset();
}

main();

