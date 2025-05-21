# LookupCafe

**LookupCafe** is an iOS application developed using **SwiftUI**, **Firebase**, and the **Google Maps SDK**. It helps users discover nearby coffee shops based on their current location, explore detailed cafe information, and personalize their experience through advanced filtering and a favorite list.

## Features

* **Location-based Discovery**: Display nearby coffee shops on a Google Map using interactive markers
* **Detailed Cafe Info**: View name, address, phone number, opening hours, rating, user reviews, and service availability
* **Favorites Management**: Add or remove cafes from a personalized "Favorites" list
* **User Authentication**: Sync user-specific data securely via Firebase Authentication (Google Sign-In)
* **Advanced Filters**: Search for cafes with specific criteria (e.g., high rating, Wi-Fi, power outlets, alcohol availability, etc.)
* **Local Caching**: Store categorized cafe data locally for faster loading and offline access
* **Cloud Sync**: Fetch and store metadata using Firebase Firestore

## Technologies Used

* **SwiftUI** – Modern declarative UI framework for iOS development
* **Google Maps SDK for iOS** – Location services and interactive map rendering
* **Firebase Firestore** – Scalable NoSQL cloud database
* **Firebase Authentication** – Google Sign-In support
* **CoreLocation & CLGeocoder** – Used for reverse geocoding and location awareness
* **Swift Concurrency** – Asynchronous data loading and UI updates

## Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/lookupCafe.git
cd lookupCafe
```

### 2. Install Dependencies

Ensure [CocoaPods](https://cocoapods.org/) is installed:

```bash
pod install
```

### 3. Configure API Keys

Set your Google Maps API key in `Info.plist`:

```xml
<key>GMSApiKey</key>
<string>YOUR_GOOGLE_MAPS_API_KEY</string>
```

If you're using Google Places or Geocoding, also add:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app uses your location to show nearby cafes.</string>
```

### 4. Open the Workspace

Use Xcode to open the `.xcworkspace` file and run the project:

```bash
open lookupCafe.xcworkspace
```

Choose a simulator or physical device to test the app.
