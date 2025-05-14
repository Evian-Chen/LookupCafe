# LookupCafe

**lookupCafe** is an iOS application developed using **SwiftUI**, **Firebase**, and **Google Maps SDK**. It provides location-based coffee shop discovery, detailed cafe information, and user personalization features including a favorite list.

## Features

* Display nearby coffee shops on a Google Map using markers
* View detailed information about each cafe, including: name, address, phone number, opening hours, rating and number of reviews
* Add or remove cafes from a personal "Favorites" list
* Sync user-specific data using Firebase Authentication
* Fetch and store cafe metadata in Firebase Realtime Database or Firestore

## Technologies Used

* **SwiftUI**: Modern declarative UI framework
* **Google Maps SDK for iOS**: Geolocation and map rendering
* **Firebase Realtime Database / Firestore**: Cloud-hosted NoSQL backend
* **Firebase Authentication**: Google Sign-In for secure user identity


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

### 3. Configure Google Maps API Key

Set your API key either in `Info.plist`:

```xml
<key>GMSApiKey</key>
<string>YOUR_GOOGLE_MAPS_API_KEY</string>
```

### 4. Open the Workspace

Use Xcode to open the `.xcworkspace` file and build the project:

```bash
open lookupCafe.xcworkspace
```

Select a simulator or real device to run the app.
