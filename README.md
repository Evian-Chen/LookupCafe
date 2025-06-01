# LookupCafe

**LookupCafe** is an iOS app built with **SwiftUI, Firebase, and the Google Maps SDK**. It enables users to discover nearby coffee shops based on their current location, browse detailed cafe information, apply advanced filters, navigate with Apple Maps, and manage a personalized list of favorites.

## Features

* Location-based discovery using Google Maps and interactive markers
* Detailed cafe information including name, address, phone number, opening hours, rating, reviews, and service availability
* Favorites list for bookmarking cafes with user-specific sync
* Google Sign-In via Firebase Authentication
* Cloud-based storage and sync using Firebase Firestore

## Technologies Used

* **SwiftUI** – Declarative user interface framework for iOS
* **Firebase Firestore** – NoSQL cloud database for metadata and user data
* **Firebase Authentication** – Google Sign-In and session management
* **Google Maps SDK for iOS** – Interactive map and location services
* **CoreLocation / CLGeocoder** – Location awareness and reverse geocoding
* **MapKit** – Used for deep-linking to Apple Maps for navigation

## Installation and Setup

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/lookupCafe.git
cd lookupCafe
```

### 2. Install Dependencies (Swift Package Manager)

Open the project in Xcode, then:

* Go to **File → Add Packages**
* Add the following packages:

  * [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk)
  * [Google Maps SDK for iOS](https://github.com/googlemaps/google-maps-ios-utils)

Select and include:

* `FirebaseFirestore`
* `FirebaseAuth`
* `GoogleMaps`
* `GooglePlaces`

> **Note:** Do not use CocoaPods. This project uses **Swift Package Manager**.

### 3. Configure Firebase and API Keys

#### a. GoogleService-Info.plist

Download your `GoogleService-Info.plist` from the [Firebase Console](https://console.firebase.google.com/) and add it to the root of your Xcode project (check "Copy items if needed").

#### b. Update Info.plist

Add the following keys to your `Info.plist`:

```xml
<key>Privacy - Location When In Use Usage Description</key>
<string>我們需要您的位置來顯示附近的咖啡店</string>

<key>GoogleSearchApi</key>
<string>YOUR_GOOGLE_SEARCH_API_KEY</string>

<key>GMSApiKey</key>
<string>YOUR_GOOGLE_MAPS_API_KEY</string>
```

Replace the keys with your credentials from the [Google Cloud Console](https://console.cloud.google.com/).

### 4. Run the Project

Open the project in Xcode:

```bash
open lookupCafe.xcodeproj
```

Select a simulator or device, then build and run the project.

## Known Issues

* **Multiple commands produced output** error in `Info.plist`
  Refer to this [HackMD note (Mandarin)](https://hackmd.io/@L5teZbLOSuegHZDK5YEvoA/BJApD5q2kg) for a solution.

